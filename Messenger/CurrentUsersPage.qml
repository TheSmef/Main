import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.1

Page{
    id: mainpage
    anchors.fill: parent
    title: stack.currentItem.title
    StackView{
        id: stack
        initialItem: currentUserPage
        anchors.fill: parent
    }
    signal updateData
    Component{
        id: currentUserPage

        Page{
            id: currentUser
            anchors.fill: parent
            title: qsTr("Моя страница")
            background: Rectangle{ color:colorMainBackGround}

            Connections{
                target: mainpage
                onUpdateData: {
                    userdataUpdated()
                }

            }

            signal userdataUpdated
            onUserdataUpdated: {
                manager.getUserData()
                lastname_l.text = manager.getUserDataList()[1];
                image_l.source = manager.getUserDataList()[0] != ""? manager.getUserDataList()[0] : "defaultIcom.png";
                firstname_l.text = manager.getUserDataList()[2]
                otch_l.text = manager.getUserDataList()[3]
                email_l.text = manager.getUserDataList()[4]
            }


            Component.onCompleted: {
                userdataUpdated()
            }


            Rectangle{
                anchors.fill: parent
                anchors.leftMargin: parent.width.valueOf() / 10
                anchors.rightMargin: parent.width.valueOf() / 10
                color: colorSideBackGround
            }

            ColumnLayout{
                anchors.topMargin: 10
                anchors.fill: parent
                Rectangle{
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    height: 230
                    anchors.leftMargin: parent.width.valueOf() / 10
                    anchors.rightMargin: parent.width.valueOf() / 10
                    color: colorSideBackGround
                    RowLayout{
                        anchors.fill: parent
                        spacing: 30
                        Item{
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            id: imagerect
                            width: 250
                            height: 250
                            radius: 200
                            Image {
                                id: image_l
                                source: "defaultIcom.png"
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: imagerect
                                }

                            }
                        }
                        ColumnLayout{
                            anchors.leftMargin: 20
                            spacing: 20
                            Label{
                                id: lastname_l
                                height: 10
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 16
                                color: colorFieldText
                            }
                            Label{
                                id: firstname_l
                                height: 10
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 16
                                color: colorFieldText
                            }
                            Label{
                                id: otch_l
                                height: 10
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 16
                                color: colorFieldText
                            }
                            Label{
                                id: email_l
                                height: 10
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 14
                                color: colorFieldText
                            }
                            Button{
                                id: buttonNext
                                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                                contentItem: Label{
                                    text: qsTr("Редактирование своих данных")
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
                                     stack.push(changeUserData)
                                }
                            }

                        }
                        Item{
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    Component{
        id: changeUserData
        Page{
            id: currentUser
            anchors.fill: parent
            title: qsTr("Редактирование данных")
            background: Rectangle{ color:colorMainBackGround}

            Component.onCompleted:  {
               manager.setChangeImagePath("")
               manager.resetEmailCode()

               manager.getUserData()

                last_name.text = manager.getUserDataList()[1];
                image.source = manager.getUserDataList()[0] != ""? manager.getUserDataList()[0] : "defaultIcom.png";
                first_name.text = manager.getUserDataList()[2]
                otch.text = manager.getUserDataList()[3]
                email.text = manager.getUserDataList()[4]
                login.text = manager.getUserDataList()[5]
            }

            ToolButton {
                anchors.top: parent.top
                anchors.left: parent.left
                width: 40
                height: 40
                HoverHandler{
                    cursorShape: Qt.PointingHandCursor
                }
                id: toolButton
                Text {
                    text: "\u25C0"
                    font.pixelSize: Qt.application.font.pixelSize * 1.6
                    color: colorFieldText
                    anchors.centerIn: parent
                }
                onClicked: {
                    updateData()
                    stack.pop()
                }
            }
            property bool codeActive: false




            ScrollView {
                clip: true
                anchors.fill: parent
                anchors.leftMargin: 50
                anchors.rightMargin: 50
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                Flickable {
                    contentHeight: 1500
                    width: parent.width.valueOf()
                    anchors.leftMargin: parent.width.valueOf() / 10
                    anchors.rightMargin: parent.width.valueOf() / 10



                    ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2
                    Layout.alignment: Qt.AlignHCenter

                    Label{
                        text:  qsTr("Личные данные")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 20
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
                    }
                    Label{
                        text:  qsTr("Фамилия")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                    }
                    RowLayout{
                        spacing: 10
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
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
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
                        height: 30
                    }
                    Label{
                        text:  qsTr("Отчество")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
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
                            anchors.margins: 10
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
                        height: 10
                    }
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }

                        Button{
                            id: buttonChangeFIO
                            HoverHandler{ cursorShape: Qt.PointingHandCursor }
                            width: 80
                            height: 50
                            contentItem: Label{
                                text: qsTr("Изменить личные данные")
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
                                manager.setNewFIO(last_name.text, first_name.text, otch.text)
                            }
                        }
                        Item{
                            Layout.fillWidth: true
                        }

                    }
                    Item{
                        height: 30
                    }
                    Label{
                        text:  qsTr("Логин и пароль")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 20
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
                    }
                    Label{
                        text:  qsTr("Логин")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
                    }
                    RowLayout{
                        spacing: 30
                        Item{
                            Layout.fillWidth: true
                        }
                        TextField{
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            id: login
                            placeholderText: qsTr("Напишите логин")
                            anchors.margins: 10
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
                        height: 30
                    }

                    Label{
                        text:  qsTr("Старый пароль")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"

                    }
                    Item{
                        height: 30
                    }
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }
                        TextField{
                            id: passOld
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            echoMode:  TextInput.Password
                            placeholderText: qsTr("Напишите старый пароль")
                            anchors.margins: 10
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

                    Label{
                        text:  qsTr("Напишите новый пароль")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
                    }
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }
                        TextField{
                            id: passNew
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            echoMode:  TextInput.Password
                            placeholderText: qsTr("Новый пароль")
                            anchors.margins: 10
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

                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }
                        TextField{
                            id: passRep
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            echoMode:  TextInput.Password
                            placeholderText: qsTr("Повторите новый пароль")
                            anchors.margins: 10
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
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }

                        Button{
                            id: buttonChangePasswordLogin
                            HoverHandler{ cursorShape: Qt.PointingHandCursor }
                            width: 80
                            height: 50
                            contentItem: Label{
                                text: qsTr("Изменить пароль и логин")
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
                                manager.setNewPassLog(login.text ,passOld.text, passNew.text, passRep.text)
                            }
                        }
                        Item{
                            Layout.fillWidth: true
                        }

                    }
                    Item{
                        height: 30
                    }

                    Label{
                        text:  qsTr("Email")
                        anchors.margins: 10
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 20
                        horizontalAlignment: "AlignHCenter"
                    }
                    Item{
                        height: 30
                    }
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }
                        TextField{
                            id: email
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            placeholderText: qsTr("Напишите электронную почту")
                            color: colorFieldText
                            implicitHeight: 40
                            implicitWidth: 300
                            maximumLength: 50
                            enabled: !codeActive
                            validator: RegExpValidator{ regExp: /^[a-zA-Z0-9@._%+-]*$/}
                        }
                        Item{
                            Layout.fillWidth: true
                        }
                    }
                    Item{
                        height: 30
                        visible: codeActive
                    }
                    Label{
                        text:  qsTr("Код подтверждения Email")
                        Layout.fillWidth: true
                        color: colorFieldText
                        font.pointSize: 14
                        horizontalAlignment: "AlignHCenter"
                        visible: codeActive
                    }
                    Item{
                        height: 30
                        visible: codeActive
                    }
                    RowLayout{
                        spacing: 10
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
                            visible: codeActive
                            anchors.margins: 10
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
                    Item{
                        height: 20
                    }
                    RowLayout{
                        spacing: 10
                        Item{
                            Layout.fillWidth: true
                        }

                        Button{
                            id: buttonChangeEmail
                            HoverHandler{ cursorShape: Qt.PointingHandCursor }
                            width: 80
                            height: 50
                            contentItem: Label{
                                text: qsTr("Изменить email")
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
                                    if(manager.setNewEmail(email.text, passConfEmail.text)){
                                        passConfEmail.text = ""
                                        manager.resetEmailCode()
                                        codeActive = false
                                    }
                                }
                                else{
                                    if (manager.sendChangeEmailCode(email.text)){
                                    codeActive = true;
                                    }
                                }
                            }
                        }
                        Item{
                            Layout.fillWidth: true
                        }

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
    }
}


