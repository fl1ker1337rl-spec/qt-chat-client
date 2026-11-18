#include "chat_network.h"
#include <QTcpSocket>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QUuid>
#include <QJsonArray>

ChatNetwork::ChatNetwork(QObject *parent) : QObject(parent), socket_(new QTcpSocket(this)){

    // 1. Generate user ID upon object creation
    clientId_ = QUuid::createUuid().toString(QUuid::WithoutBraces);
    qDebug() << "User ID:" << clientId_;

    // 2. Handle incoming data from the server
    connect(socket_, &QTcpSocket::readyRead, this, [this](){
        QByteArray data = socket_->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (!doc.isNull() && doc.isObject()) {
            QJsonObject jsonObj = doc.object();
            QString type = jsonObj["type"].toString();

            if (type == "user_list") {
                QJsonArray usersArray = jsonObj["users"].toArray();
                QVariantList listForQml;

                for (const QJsonValue &val : std::as_const(usersArray)) {
                    QJsonObject userObj = val.toObject();
                    QVariantMap map;
                    map["id"] = userObj["id"].toString();
                    map["name"] = userObj["name"].toString();
                    map["lastMsg"] = "Online";
                    listForQml.append(map);
                }

                // Emit signal to QML with the new user list
                emit userListReceived(listForQml);
            }
            else if (type == "private_message") {
                QString content = jsonObj["content"].toString();
                QString senderName = jsonObj["senderName"].toString();
                QString senderId = jsonObj["senderID"].toString();

                emit messageReceived(senderId, senderName, content);
            }
        }
    });

    // 3. When connection is SUCCESSFULLY established — send registration
    connect(socket_, &QTcpSocket::connected, this, [this](){
        qDebug() << "Client successfully connected to the server!";

        QJsonObject regObj;
        regObj["type"] = "register";
        regObj["senderId"] = clientId_;

        socket_->write(QJsonDocument(regObj).toJson(QJsonDocument::Compact));
    });

    connect(socket_, &QTcpSocket::disconnected, this, [this](){
        qDebug() << "Client disconnected from the server!";
    });
}

void ChatNetwork::connectToServer(const QString &ip, qint16 port){
    if(socket_){
        socket_->connectToHost(ip, port);
    }
}

void ChatNetwork::userName(const QString &username){
    if(socket_ && socket_->state() == QAbstractSocket::ConnectedState) {
        QJsonObject jsonObj;
        jsonObj["type"] = "auth";
        jsonObj["username"] = username;
        jsonObj["senderID"] = clientId_;
        jsonObj["timestamp"] = QDateTime::currentMSecsSinceEpoch();

        QJsonDocument doc(jsonObj);
        socket_->write(doc.toJson(QJsonDocument::Compact));
        qDebug() << "Sent username to server:" << username;
    }
}

void ChatNetwork::sendMessage(const QString &message){
    if(socket_ && socket_->state() == QTcpSocket::ConnectedState){
        QJsonObject jsonObj;
        jsonObj["type"] = "private_message";
        jsonObj["senderID"] = clientId_;
        jsonObj["recipientID"] = currentRecipientId_;
        jsonObj["content"] = message;
        jsonObj["timestamp"] = QDateTime::currentMSecsSinceEpoch();

        QJsonDocument doc(jsonObj);
        QByteArray jsonData = doc.toJson(QJsonDocument::Compact);

        qDebug() << "Sending message with ID:" << clientId_ << "to" << currentRecipientId_ << "text:" << message;

        socket_->write(jsonData);
    } else {
        qDebug() << "Cannot send message, no connection to the server!";
    }
}

void ChatNetwork::selectRecipient(const QString &recipientId) {
    currentRecipientId_ = recipientId;
    qDebug() << "Active chat selected with recipient ID:" << currentRecipientId_;
}