import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3

Page{
    anchors.fill: parent
    title: stack.currentItem.title
    StackView{
        property int id: -2
        id: stack
        initialItem: searchBanUserPage
        anchors.fill: parent
    }
    Component{
        id: searchBanUserPage
        Page{
            id: searchBanUser
            anchors.fill: parent
            title: qsTr("Чёрный список")
            background: Rectangle{ color:colorMainBackGround}
            Component.onCompleted:  {
                manager.setRefreshBaned(true)
            }
            Component.onDestruction: {
                manager.setRefreshBaned(false)
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
                        font.pointSize: 11
                        placeholderTextColor: Qt.lighter(colorFieldText, 1.1)
                        background: Rectangle{ width: parent.width.valueOf(); height:parent.height.valueOf(); radius: 15; color: "white"; border.color: parent.focus ? Qt.lighter(colorFieldText, 1.2) : colorFieldText; border.width: parent.focus ? 2.5 : 0.5 }
                        placeholderText: qsTr("Поиск пользователя")
                        color: colorFieldText
                        Layout.fillWidth: true
                        maximumLength: 200
                        validator: RegExpValidator{ regExp: /^[a-zA-Zа-яА-Я0-9]*$/}
                        Keys.onPressed: {
                            if (((event.key == Qt.Key_Enter) || event.key == Qt.Key_Return))
                            {
                                convs.model = manager.getBanedUsers(search.text)
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
                            convs.model = manager.getBanedUsers(search.text)
                        }
                    }



                }

                Flickable{
                    anchors.fill: parent
                    anchors.topMargin: 45
                    ListView{
                        id: convs
                        anchors.fill: parent
                        model: manager.getBanedUsers()
                        spacing: 10
                        clip: true



                        delegate: Rectangle{
                            height: 140
                            radius: 10
                            color: mouse.containsMouse ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                            anchors.margins: 15
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
                                    source: model.file_content_imagescaled == ""?  "defaultIcom.png" : manager.getImageBytes(model.file_content_imagescaled)
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: imagerect
                                    }

                                }
                            }
                            ColumnLayout{
                                anchors.top: imagerect.top
                                anchors.bottom: imagerect.bottom
                                anchors.left: imagerect.right
                                anchors.leftMargin: 30
                                spacing: -1
                                Label{
                                    id: llabel
                                    text: model.last_name
                                    verticalAlignment: "AlignVCenter"
                                    font.pointSize: 12
                                    color: colorButtonText
                                }
                                Label{
                                    id: flabel
                                    text: model.first_name
                                    verticalAlignment: "AlignVCenter"
                                    font.pointSize: 12
                                    color: colorButtonText
                                }
                                Label{
                                    id: olabel
                                    text: model.otch
                                    verticalAlignment: "AlignVCenter"
                                    font.pointSize: 12
                                    color: colorButtonText
                                }
                                Label{
                                    id: elabel
                                    text: model.email
                                    verticalAlignment: "AlignVCenter"
                                    font.pointSize: 9
                                    color: colorButtonText
                                }
                            }

                            MouseArea{
                                id: mouse
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    stack.id = model.userban_id
                                    stack.push(userpage)
                                }
                            }

                            Button{
                                id: buttonDelete
                                anchors.bottom: parent.bottom
                                anchors.top:  parent.top
                                anchors.right: parent.right
                                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                                width: 80
                                height: 50
                                contentItem: Label{
                                    text: qsTr("Удалить")
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
                                    manager.restoreUser(model.userban_id, model.id_banlist)
                                }
                            }
                        }
                    }
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


}
