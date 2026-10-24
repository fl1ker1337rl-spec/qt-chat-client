import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root
    color: "#0b0f19"

    // Сигнал, который сообщает главной программе, что пользователь нажал войти
    signal loginSuccessful(string username)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: 300

        // Заголовок
        Text {
            text: "Вход в MessTag"
            color: "white"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        // Поле ввода никнейма / ID
        TextField {
            id: usernameInput
            Layout.fillWidth: true
            placeholderText: "Введите ваш ник"
            color: "white"
            placeholderTextColor: "#6b7280"
            font.pixelSize: 14

            background: Rectangle {
                color: "#1f2937"
                radius: 8
            }

            // Нажатие Enter на клавиатуре тоже вызывает отправку
            onAccepted: loginButton.clicked()
        }

        // Кнопка входа
        Button {
            id: loginButton
            Layout.fillWidth: true
            height: 40

            contentItem: Text {
                text: "Войти в чат"
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }

            background: Rectangle {
                color: "#2563eb"
                radius: 8
            }

            onClicked: {
                if (usernameInput.text.trim() !== "") {
                    // Передаем введенный текст наружу
                    root.loginSuccessful(usernameInput.text.trim())
                }
            }
        }
    }
}
