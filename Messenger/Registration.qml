import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.1


Page{
    id: regpage
    anchors.fill: parent
    title: qsTr("Регистрация")

    Component.onCompleted:  {
       manager.setChangeImagePath("")
       manager.resetEmailCode()
    }




    property bool codeActive: false

    background: Rectangle{ color:colorMainBackGround}
    ScrollView {
        clip: true
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        Flickable {
            contentHeight: 880
            width: parent.width
            ColumnLayout{
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2
            Layout.alignment: Qt.AlignHCenter


            Item{
                height: 20
            }
            Label{
                text:  qsTr("Фамилия")
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
                Item{
                    width: 100
                }

                TextField{
                    id: last_name
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Напишите фамилию")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 300
                    maximumLength: 50
                    validator: RegExpValidator{ regExp: /^[а-яА-Я]*$/}
                }
                Rectangle {
                    id: imagerect
                    width: 100
                    height: 100
                    radius: 50
                    Image {
                        id: image
                        source: "defaultIcom.png"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: imagerect
                            }

                    }
                    MouseArea{
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: {
                            fileDialog.open();
                        }


                    }
                }

                Item{
                    Layout.fillWidth: true
                }
            }
            Label{
                text:  qsTr("Имя")
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
                    id:first_name
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Напишите имя")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 300
                    maximumLength: 50
                    validator: RegExpValidator{ regExp: /^[а-яА-Я]*$/}

                }
                Item{
                    Layout.fillWidth: true
                }
            }
            Item{
                height: 20
            }
            Label{
                text:  qsTr("Отчество")
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
                    id: otch
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Напишите отчество")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 300
                    maximumLength: 50
                    validator: RegExpValidator{ regExp: /^[а-яА-Я]*$/}
                }
                Item{
                    Layout.fillWidth: true
                }
            }
            Item{
                height: 20
            }

            Label{
                text:  qsTr("Логин")
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
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Напишите логин")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 300
                    maximumLength: 30
                    validator: RegExpValidator{ regExp: /^[a-zA-Z0-9]*$/}
                }
                Item{
                    Layout.fillWidth: true
                }
            }
            Item{
                height: 20
            }

            Label{
                text:  qsTr("Email")
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
                    id: email
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Напишите электронную почту")
                    anchors.margins: 20
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
                    id: pass
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
                height: 20
            }

            Label{
                text:  qsTr("Повторите пароль")
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
                    id: passRep
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    echoMode:  TextInput.Password
                    placeholderText: qsTr("Повторите пароль")
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
                height: 20
                visible: codeActive
            }

            Label{
                text:  qsTr("Код подтверждения Email")
                anchors.margins: 20
                Layout.fillWidth: true
                color: colorFieldText
                font.pointSize: 14
                horizontalAlignment: "AlignHCenter"
                visible: codeActive
            }
            RowLayout{
                spacing: 30
                visible: codeActive
                Item{
                    Layout.fillWidth: true
                }
                TextField{
                    id: passConfEmail
                    font.pointSize: 11
                    placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                    background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                    placeholderText: qsTr("Введите код подтверждения Email")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 300
                    maximumLength: 10
                    validator: RegExpValidator{ regExp: /^[0-9]*$/}
                }
                Item{
                    Layout.fillWidth: true
                    visible: codeActive
                }
            }
            //
            Item{
                height: 50
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
                        text: qsTr("Вернуться к авторизации")
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
                        newPushAuth()
                    }
                }

                Button{
                    id: buttonRegistration
                    HoverHandler{ cursorShape: Qt.PointingHandCursor }
                    width: 80
                    height: 50
                    contentItem: Label{
                        text: qsTr("Зарегистрироваться")
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
                        if (codeActive){
                            newReg(last_name.text, first_name.text, otch.text, login.text, email.text, pass.text, passRep.text, passConfEmail.text);
                        }
                        else{
                            if (manager.sendEmailCode(last_name.text, first_name.text, otch.text, login.text, email.text, pass.text, passRep.text)){
                            email.enabled = false;
                            codeActive = true;
                            }
                        }


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
    }


    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        fileMode: FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
        Component.onCompleted: {
            fileDialog.fileMode = 0;
        }
        onAccepted: {
            if(manager.setChangeImagePath(fileDialog.file)){
                image.source = fileDialog.file;
            }
        }
    }
}
