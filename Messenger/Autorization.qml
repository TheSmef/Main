import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Page{
    id: loginpage
    anchors.fill: parent
    title: qsTr("Авторизация")
    background: Rectangle{ color:colorMainBackGround}

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 10
        Item{
            Layout.fillHeight: true
        }

        Item{
            height: 40
        }
        Label{
            text:  qsTr("Логин/Email")
            anchors.margins: 20
            Layout.fillWidth: true
            color: colorFieldText
            font.pointSize: 14
            horizontalAlignment: "AlignHCenter"
        }
        RowLayout{
            spacing: 30
            Item{
                Layout.fillWidth: true
            }
            TextField{
                id: login
                placeholderText: qsTr("Напишите логин или email")
                anchors.margins: 20
                font.pointSize: 11
                placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                color: colorFieldText

                implicitHeight: 40
                implicitWidth: 300

                maximumLength: 50
                validator: RegExpValidator{ regExp: /^[a-zA-Z0-9@._%+-]*$/}
            }
            Item{
                Layout.fillWidth: true
            }
        }
        Item{
            height: 20
        }
        Label{
            text:  qsTr("Пароль")
            anchors.margins: 20
            Layout.fillWidth: true
            color: colorFieldText
            font.pointSize: 14
            horizontalAlignment: "AlignHCenter"
        }
        RowLayout{
            spacing: 30
            Item{
                Layout.fillWidth: true
            }
            TextField{
                id:pass
                font.pointSize: 11
                placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                echoMode:  TextInput.Password
                placeholderText: qsTr("Напишите пароль")
                anchors.margins: 20
                color: colorFieldText
                implicitHeight: 40
                implicitWidth: 300
                maximumLength: 30
                validator: RegExpValidator{ regExp: /^[a-zA-Z0-9!@#$%^&*]*$/}
            }
            Item{
                Layout.fillWidth: true
            }
        }

        Item{
            height: 30
        }
        RowLayout{
            spacing: 30
            Item{
                Layout.fillWidth: true
            }
            Button{
                id: buttonNext
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                contentItem: Label{
                    text: qsTr("Регистрация")
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                width: 80
                height: 50
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    implicitHeight: 50
                    implicitWidth: 80
                    radius: 5
                }
                onClicked: {
                    newRegPush()
                }
            }

            Button{
                id: buttonRegistration
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                width: 80
                height: 50
                contentItem: Label{
                    text: qsTr("Войти")
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    implicitHeight: 50
                    implicitWidth: 80
                    radius: 5
                }
                onClicked: {
                    newAuth(login.text, pass.text)
                }
            }
            Item{
                Layout.fillWidth: true
            }

        }
        RowLayout{
            Item{
                Layout.fillWidth: true
            }
            Button{
                id: buttonReset
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                width: 50
                height: 10
                contentItem: Label{
                    text: qsTr("Востановить доступ")
                    color: colorFieldText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorMainBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorMainBackGround, 1.2) : colorMainBackGround)
                    implicitHeight: 10
                    implicitWidth: 50
                    radius: 5
                }
                onClicked: {
                    newResetPass()
                }
            }
            Item{
                Layout.fillWidth: true
            }
        }
        Item{
            Layout.fillHeight: true
        }
        Item{
            Layout.fillHeight: true
        }
    }

}
