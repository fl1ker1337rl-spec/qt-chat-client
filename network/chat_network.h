#pragma once
#include <QObject>
#include <QString>
#include <QDebug>

class QTcpSocket;

class ChatNetwork : public QObject
{
    Q_OBJECT
public:
    explicit ChatNetwork(QObject *parent = nullptr);
    virtual ~ChatNetwork() noexcept = default;
    void connectToServer(const QString &ip, const qint16 port);

    Q_INVOKABLE void userName(const QString &username);
    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void selectRecipient(const QString &recipientId);
    Q_INVOKABLE QString getClientId() const {
        return clientId_;
    }

signals:
    void messageReceived(const QString &senderId, const QString &senderName, const QString &text);
    void userListReceived(const QVariantList &users);

private:
    QTcpSocket *socket_{nullptr};
    QString clientId_;
    QString currentRecipientId_;

    ChatNetwork(const ChatNetwork&) = delete;
    ChatNetwork& operator=(ChatNetwork&) = delete;
    ChatNetwork(ChatNetwork&&) = delete;
    ChatNetwork& operator=(ChatNetwork&&) = delete;

};


