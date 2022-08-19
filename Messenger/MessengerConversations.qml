import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.1

Page{
    anchors.fill: parent
    title: stack.currentItem.title
    StackView{
        signal updateUsersList
        property int id: -2
        property int id_conv: -2
        property int id_chat_user: -2
        id: stack
        initialItem: pageconv
        anchors.fill: parent
    }
    Component{
        id: pageconv
        Page{
            id: conv
            anchors.fill: parent
            title: qsTr("Беседы")
            background: Rectangle{ color:colorMainBackGround}
            Component.onCompleted:  {
                manager.setChangeImagePath("")
                manager.setRefreshConv(true)
                manager.resetConvFilter()
            }
            Component.onDestruction: {
                manager.setRefreshConv(false)
            }


            Popup {
                id: createpopup
                onOpened: {
                    manager.setChangeImagePath("")
                }

                anchors.centerIn: parent
                width: 430
                height: 170
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                contentItem: Rectangle {
                    anchors.fill: parent
                    color: colorMainBackGround
                    Text {
                        id: popuptext
                        anchors.margins: 10
                        text: qsTr("Создание беседы")
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
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 30
                        Item{
                            Layout.fillWidth: true
                        }

                        TextField{
                            id: conv_name
                            font.pointSize: 11
                            placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                            background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                            placeholderText: qsTr("Напишите название беседы")
                            anchors.margins: 10
                            color: colorFieldText
                            implicitHeight: 40
                            implicitWidth: 260
                            maximumLength: 50
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
                            manager.createConversation(conv_name.text)
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
                            createpopup.close()
                        }
                    }
                }
                onClosed: {
                    conv_name.text = ""
                    popupimage.source = "defaultIcom.png"
                }
            }


            Rectangle{
                anchors.fill: parent
                anchors.leftMargin: parent.width.valueOf() / 10
                anchors.rightMargin: parent.width.valueOf() / 10
                color: colorSideBackGround



                RowLayout{
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.fillWidth: true
                    height: 40
                    spacing: 5
                    TextField{
                        id: search
                        height: 50
                        font.pointSize: 11
                        placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                        background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                        placeholderText: qsTr("Поиск беседы")
                        maximumLength: 50
                        color: colorFieldText
                        Layout.fillWidth: true

                        validator: RegExpValidator{ regExp: /^[a-zA-Zа-яА-Я0-9 ]*$/}
                        Keys.onPressed: {
                            if (((event.key == Qt.Key_Enter) || event.key == Qt.Key_Return))
                            {
                                convs.model = manager.getConversations(search.text)
                            }
                        }
                    }
                    Button{
                        id: buttonSearch
                        HoverHandler{ cursorShape: Qt.PointingHandCursor }
                        contentItem: Label{
                            id: label
                            text: qsTr("Поиск")
                            color: colorButtonText
                            anchors.fill: parent
                            horizontalAlignment: "AlignHCenter"
                            verticalAlignment: "AlignVCenter"
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                                 (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                            implicitHeight: 40
                            implicitWidth: 70
                            radius: 5
                        }
                        onClicked: {
                            convs.model = manager.getConversations(search.text)
                        }
                    }
                    ToolSeparator{

                    }

                    Button{
                        id: buttonCreate
                        HoverHandler{ cursorShape: Qt.PointingHandCursor }

                        contentItem: Label{
                            text: qsTr("Создать беседу")
                            color: colorButtonText
                            anchors.fill: parent
                            horizontalAlignment: "AlignHCenter"
                            verticalAlignment: "AlignVCenter"
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                                 (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                            implicitHeight: 40
                            implicitWidth: 70
                            radius: 5
                        }
                        onClicked: {
                            createpopup.open()
                        }
                    }


                }

                Flickable{
                    anchors.fill: parent
                    anchors.topMargin: 45


                    ListView{
                        id: convs
                        anchors.fill: parent
                        model: manager.getConversations()
                        spacing: 10
                        clip: true
                        delegate: Rectangle{
                            height: 140
                            radius: 10
                            color: mouse.containsMouse ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                            anchors.margins: 15
                            Layout.fillWidth: true
                            anchors.left: parent.left
                            anchors.right: parent.right
                            Rectangle {
                                id: imagerect
                                width: 120
                                height: 120
                                radius: 25
                                anchors.margins: 10
                                anchors.top: parent.top
                                anchors.left: parent.left
                                Image {
                                    id: image
                                    source: model.chatphoto == ""?  "defaultIcom.png" : manager.getImageBytes(model.chatphoto)
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: imagerect
                                    }

                                }
                            }
                            Label{
                                anchors.left: imagerect.right
                                anchors.top: imagerect.top
                                height: 40
                                anchors.topMargin: 10
                                anchors.leftMargin: 20
                                text: model.name_chat
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 18
                                color: colorButtonText
                            }
                            Rectangle {
                                visible: model.content_message != ""
                                id: userimagerect
                                width: 50
                                height: 50
                                radius: 50
                                anchors.margins: 20
                                anchors.bottom: parent.bottom
                                anchors.left: imagerect.right
                                Image {
                                    id: userimage
                                    source: model.userphoto == ""?  "defaultIcom.png" : manager.getImageBytes(model.userphoto)
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: userimagerect
                                    }

                                }
                            }
                            Label{
                                visible: model.content_message != ""
                                anchors.left: userimagerect.right
                                anchors.right: parent.right
                                anchors.top: userimagerect.top
                                anchors.bottom: userimagerect.bottom
                                height: 40
                                elide: Label.ElideRight
                                anchors.leftMargin: 5
                                text: model.content_message
                                width: 100
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 12
                                color: colorButtonText
                            }
                            Label{
                                visible: model.content_message != ""
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 40
                                anchors.rightMargin: 20
                                text: model.date_message
                                width: 100
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 10
                                color: colorButtonText
                            }

                            MouseArea{
                                id: mouse
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                onClicked: {
                                    stack.id_conv = model.id_chat
                                    stack.id_chat_user = model.id_chat_user
                                    stack.push(pageedconv)
                                }
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
                        popupimage.source = fileDialog.file;
                    }
                }
            }

        }
    }
    Component{
        id: pageedconv
        ConversationWithRed{
            id: convc
            Connections{
                target: stack
                onUpdateUsersList: {
                    updateconvUsers()
                }

            }
        }
    }
    Component{
        id: userpage

        OtherUserPage{
            id: user
        }
    }
    Component{
        id: addUser
        AddToConvPage{
            id: addpage
        }
    }

}
