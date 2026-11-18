import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root
    color: "#0b0f19"

    // Signal that informs the main program that the user clicked login
    signal loginSuccessful(string username)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: 300

        // Header
        Text {
            text: "Messtag Login"
            color: "white"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        // Username / ID input field
        TextField {
            id: usernameInput
            Layout.fillWidth: true
            placeholderText: "Enter your username"
            color: "white"
            placeholderTextColor: "#6b7280"
            font.pixelSize: 14

            background: Rectangle {
                color: "#1f2937"
                radius: 8
            }

            onAccepted: loginButton.clicked()
        }

        // Login button
        Button {
            id: loginButton
            Layout.fillWidth: true
            height: 40

            contentItem: Text {
                text: "Enter chat"
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
                    // Pass the entered text outside
                    root.loginSuccessful(usernameInput.text.trim())
                }
            }
        }
    }
}