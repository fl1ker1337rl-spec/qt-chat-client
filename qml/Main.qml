import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Window {
    width: 800
    height: 600
    visible: true
    title: "MessTag"

    // Переменные состояния
    property bool isLoggedIn: false
    property string currentUsername: ""
    property string selectedUserId: ""
    property string selectedUserName: "Выбранный чат"

    // Словарь для хранения истории сообщений по ID каждого пользователя
    property var chatHistories: ({})

    // Модель для списка других пользователей онлайн
    ListModel {
        id: onlineUsersModel
    }

    // Ловим сигналы из C++
    Connections {
        target: chatNetwork

        function onUserListReceived(users) {
            onlineUsersModel.clear()
            for (var i = 0; i < users.length; i++) {
                // Добавляем в список только тех, кто НЕ является тобой
                if (users[i].name !== currentUsername) {
                    onlineUsersModel.append(users[i])
                }
            }
        }

        function onMessageReceived(senderId, senderName, text) {
            if (!text || text.trim() === "") return;

            if (senderId === selectedUserId) {
                messageModel.append({"sender": senderName, "text": text})
            }

            if (!chatHistories[senderId]) {
                chatHistories[senderId] = []
            }
            chatHistories[senderId].push({"sender": senderName, "text": text})
        }
    }

    // ==========================================
    // 1. ЭКРАН АВТОРИЗАЦИИ
    // ==========================================
    Loader {
        id: authLoader
        anchors.fill: parent
        source: "views/register_view.qml"
        visible: !isLoggedIn
        z: 10

        onItemChanged: {
            if (item) {
                item.loginSuccessful.connect(function(username) {
                    console.log("Успешный вход под именем:", username)
                    currentUsername = username
                    chatNetwork.userName(username);
                    isLoggedIn = true
                })
            }
        }
    }

    // ==========================================
    // 2. ОСНОВНОЙ ИНТЕРФЕЙС ЧАТА
    // ==========================================
    Row {
        anchors.fill: parent
        enabled: isLoggedIn
        opacity: isLoggedIn ? 1.0 : 0.2

        // Узкая левая панель
        Rectangle {
            width: 70
            height: parent.height
            color: "#0b0f19"
        }

        // Средняя панель (Свой профиль сверху + Список чатов ниже)
        Rectangle {
            width: 260
            height: parent.height
            color: "#111827"
            border.color: "#1f2937"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // === СТАТИЧНАЯ ПЛАШКА ПРОФИЛЯ СВЕРХУ ===
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: "#111827"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            spacing: 10

                            Rectangle {
                                width: 35
                                height: 35
                                radius: 17.5
                                color: "#374151"

                                Text {
                                    anchors.centerIn: parent
                                    text: currentUsername ? currentUsername.charAt(0) : ""
                                    color: "white"
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: currentUsername + " (Вы)"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: "В сети (Ваш аккаунт)"
                                    color: "#9ca3af"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Тонкая разделительная черта под профилем
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 5
                            color: "#1f2937"
                        }
                    }
                }

                // === СПИСОК ОСТАЛЬНЫХ ПОЛЬЗОВАТЕЛЕЙ ===
                ListView {
                    id: chatListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    model: onlineUsersModel
                    highlightFollowsCurrentItem: false

                    delegate: Rectangle {
                        width: chatListView.width
                        height: 55
                        radius: 8
                        color: model.id === selectedUserId ? "#2563eb" : "#1f2937"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (model.id === selectedUserId) return;

                                chatNetwork.selectRecipient(model.id);
                                selectedUserId = model.id;
                                selectedUserName = model.name;

                                messageModel.clear()
                                if (chatHistories[model.id]) {
                                    var hist = chatHistories[model.id]
                                    for (var j = 0; j < hist.length; j++) {
                                        if (hist[j].text && hist[j].text.trim() !== "") {
                                            messageModel.append(hist[j])
                                        }
                                    }
                                }

                                console.log("Выбран чат с пользователем:", model.name);
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                width: 35
                                height: 35
                                radius: 17.5
                                color: model.id === selectedUserId ? "#1e40af" : "#374151"

                                Text {
                                    anchors.centerIn: parent
                                    text: model.name ? model.name.charAt(0) : ""
                                    color: "white"
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: model.lastMsg
                                    color: "#9ca3af"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // Правая панель (Область переписки)
        Rectangle {
            width: parent.width - 330
            height: parent.height
            color: "#0f172a"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // Шапка чата
                Rectangle {
                    Layout.fillWidth: true
                    height: 55
                    color: "#111827"
                    border.color: "#1f2937"
                    border.width: 1

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        text: selectedUserId === "" ? "Выберите чат из списка слева" : "Чат с: " + selectedUserName
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }

                // История сообщений текущего чата
                ListView {
                    id: messageListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    leftMargin: 15
                    rightMargin: 15
                    topMargin: 15
                    bottomMargin: 15
                    spacing: 10

                    model: ListModel {
                        id: messageModel
                    }

                    delegate: Item {
                        width: messageListView.width
                        height: (model.text && model.text.trim() !== "") ? contentCol.height + 16 : 0
                        visible: model.text && model.text.trim() !== ""

                        Column {
                            id: contentCol
                            readonly property bool isMe: model.sender === "Я"

                            anchors.right: isMe ? parent.right : undefined
                            anchors.left: isMe ? undefined : parent.left
                            width: Math.min(messageListView.width * 0.7, 400)

                            Rectangle {
                                width: parent.width
                                height: msgText.implicitHeight + 20
                                color: model.sender === "Я" ? "#2563eb" : "#1f2937"
                                radius: 10
                                visible: model.text && model.text.trim() !== ""

                                Text {
                                    id: msgText
                                    text: model.text || ""
                                    color: "white"
                                    font.pixelSize: 14
                                    wrapMode: Text.Wrap
                                    anchors.fill: parent
                                    anchors.margins: 10
                                }
                            }
                        }
                    }
                }

                // Панель ввода сообщения
                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    color: "#111827"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        TextField {
                            id: inputField
                            Layout.fillWidth: true
                            placeholderText: selectedUserId === "" ? "Сначала выберите чат..." : "Написать сообщение..."
                            enabled: selectedUserId !== ""
                            color: "white"
                            placeholderTextColor: "#6b7280"
                            font.pixelSize: 14

                            background: Rectangle {
                                color: "#1f2937"
                                radius: 8
                            }

                            onAccepted: sendButton.clicked()
                        }

                        Button {
                            id: sendButton
                            text: "Отправить"
                            enabled: selectedUserId !== ""

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: true
                            }

                            background: Rectangle {
                                color: parent.enabled ? "#2563eb" : "#374151"
                                radius: 8
                            }

                            onClicked: {
                                if (inputField.text.trim() !== "") {
                                    var msgText = inputField.text
                                    chatNetwork.sendMessage(msgText)

                                    messageModel.append({"sender": "Я", "text": msgText})

                                    if (!chatHistories[selectedUserId]) {
                                        chatHistories[selectedUserId] = []
                                    }
                                    chatHistories[selectedUserId].push({"sender": "Я", "text": msgText})

                                    inputField.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}