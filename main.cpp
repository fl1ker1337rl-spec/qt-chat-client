#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "network/chat_network.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    ChatNetwork chatNetwork;

    chatNetwork.connectToServer("127.0.0.1", 12345);
    engine.rootContext()->setContextProperty("chatNetwork", &chatNetwork);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("messenger", "Main");

    return QGuiApplication::exec();
}
