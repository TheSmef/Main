import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import Qt.labs.platform 1.1



Page{
    id: currentUser
    anchors.fill: parent
    title: qsTr("Пользователь")
    background: Rectangle{ color:colorMainBackGround}

    property bool isBlocked: manager.isBlocked(id.valueOf())

    property bool isIBlocked: manager.isIBlocked(id.valueOf())


    Component.onCompleted: {
        manager.setChangeImagePath("")
        manager.getUserData(id.valueOf())
        lastname_l.text = manager.getUserDataList()[1];
        image_l.source = manager.getUserDataList()[0] != ""? manager.getUserDataList()[0] : "defaultIcom.png";
        firstname_l.text = manager.getUserDataList()[2]
        otch_l.text = manager.getUserDataList()[3]
        email_l.text = manager.getUserDataList()[4]
    }


    Popup {
        id: createpopup
        onOpened: {
            manager.setChangeImagePath("")
        }

        anchors.centerIn: parent
        width: 400
        height: 170
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        contentItem: Rectangle {
            anchors.fill: parent
            color: colorMainBackGround
            Text {
                id: popuptext
                anchors.margins: 10
                text: qsTr("Создание личной беседы")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                color: colorFieldText
                font.pixelSize: 14
            }
            RowLayout{
                anchors.top:  popuptext.bottom
                anchors.left: parent
                anchors.right: parent
                anchors.margins: 10
                spacing: 30
                Item{
                    Layout.fillWidth: true
                }

                TextField{
                    id: conv_name
                    placeholderText: qsTr("Напишите название беседы")
                    anchors.margins: 20
                    color: colorFieldText
                    implicitHeight: 40
                    implicitWidth: 210
                    maximumLength: 80
                    validator: RegExpValidator{ regExp: /^[а-яА-Яa-zA-Z0-9 ]*$/}
                }
                Rectangle {
                    id: popupimagerect
                    width: 80
                    height: 80
                    radius: 50
                    Image {
                        id: popupimage
                        source: "defaultIcom.png"
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: popupimagerect
                        }

                    }
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            fileDialog.open();
                        }


                    }
                }
            }

            Button{
                id: buttonCreateConv
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 15
                width: 70
                height: 25
                contentItem: Label{
                    text: qsTr("Создать")
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
                    manager.createPersonalConv(id.valueOf(), conv_name.text)
                    conv_name.text = ""
                    popupimage.source = "defaultIcom.png"
                    createpopup.close()
                }
            }
            Button{
                id: buttonRevert
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 15
                width: 70
                height: 25
                contentItem: Label{
                    text: qsTr("Отмена")
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
                    conv_name.text = ""
                    popupimage.source = "defaultIcom.png"
                    createpopup.close()
                }
            }
        }
    }


    Rectangle{
        anchors.fill: parent
        anchors.leftMargin: parent.width.valueOf() / 10
        anchors.rightMargin: parent.width.valueOf() / 10
        color: colorSideBackGround
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
                stack.pop()
            }
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
                    RowLayout{
                    Button{
                        id: buttonConv
                        visible: !isIBlocked && !isBlocked
                        HoverHandler{ cursorShape: Qt.PointingHandCursor }
                        contentItem: Label{
                            text: qsTr("Создать личную беседу")
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
                            createpopup.open()
                        }
                    }
                    Button{
                        id: buttonBan
                        HoverHandler{ cursorShape: Qt.PointingHandCursor }
                        contentItem: Label{
                            text: isBlocked ? qsTr("Разблокировать пользователя") : qsTr("Заблокировать пользователя")
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
                            if(!isBlocked){
                                if(manager.blockUser(id.valueOf())){
                                    isBlocked = true
                                }
                            }
                            else{
                                if(manager.restoreUser(id.valueOf())){
                                    isBlocked = false
                                }
                            }
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
                popupimage.source = fileDialog.file;
            }
        }
    }
}
