#include "chat_network.h"
#include <QTcpSocket>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QUuid>
#include <QJsonArray>

ChatNetwork::ChatNetwork(QObject *parent) : QObject(parent), socket_(new QTcpSocket(this)){

    // 1. Генерируем ID пользователя при создании объекта
    clientId_ = QUuid::createUuid().toString(QUuid::WithoutBraces);
    qDebug() << "ID пользователя:" << clientId_;

    // 2. Обработка входящих данных от сервера
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
                    map["lastMsg"] = "В сети";
                    listForQml.append(map);
                }

                // Эмитим сигнал в QML с новым списком пользователей
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

    // 3. Когда соединение УСПЕШНО установлено — отправляем регистрацию
    connect(socket_, &QTcpSocket::connected, this, [this](){
        qDebug() << "Клиент успешно подключился к серверу!";

        QJsonObject regObj;
        regObj["type"] = "register";
        regObj["senderId"] = clientId_;

        socket_->write(QJsonDocument(regObj).toJson(QJsonDocument::Compact));
    });

    connect(socket_, &QTcpSocket::disconnected, this, [this](){
        qDebug() << "Клиент отключился от сервера!";
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
        qDebug() << "Отправлен никнейм на сервер:" << username;
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

        qDebug() << "Отправка сообщения с ID:" << clientId_ << "для" << currentRecipientId_ << "текст:" << message;

        socket_->write(jsonData);
    } else {
        qDebug() << "Невозможно отправить сообщение, нет соединения с сервером!";
    }
}

void ChatNetwork::selectRecipient(const QString &recipientId) {
    currentRecipientId_ = recipientId;
    qDebug() << "Выбран активный чат с получателем ID:" << currentRecipientId_;
}