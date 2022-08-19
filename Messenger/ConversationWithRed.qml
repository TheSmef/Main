import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.1

Page{
    id: conv
    anchors.fill: parent
    background: Rectangle{color: colorMainBackGround}
    property bool isCreator: false
    property int imageId: -1
    signal updateconvUsers
    onUpdateconvUsers: {
        convUsers.model = manager.getUsersForConv(id_conv.valueOf())
    }

    signal fillNeaded
    onFillNeaded: {
        manager.getChatData(id_conv.valueOf())
        title = manager.chatData()[0]
        popupimage.source = manager.chatData()[1] == "" ? "defaultIcom.png" : manager.chatData()[1]
        image.source = manager.chatData()[1] == "" ? "defaultIcom.png" : manager.chatData()[1]
        convName.text = manager.chatData()[0]
        conv_name.text = manager.chatData()[0]
    }

    Component.onCompleted: {
        manager.setChangeImagePath("")
        if (manager.hasConv(id_conv.valueOf())){
            manager.setCurrentConversation(id_conv.valueOf())
            fillNeaded()
            isCreator = manager.isCreator(id_conv.valueOf())
        }
        manager.resetFileSend()
    }

    Component.onDestruction: {
        manager.setCurrentConversation(-1)
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
    ToolButton {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 40
        height: 40
        HoverHandler{
            cursorShape: Qt.PointingHandCursor
        }
        id: listOfUsers
        Text {
            text: "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            color: colorFieldText
            anchors.centerIn: parent
        }
        onClicked: {
            drawer.open()
        }
    }

    Popup {
        id: imagecheck
        onOpened: {
            imagepopup.source = manager.getFullImage(imageId.valueOf())
        }
        onClosed: {
            imagepopup.source = ""
        }
        background.visible: false
        anchors.centerIn: parent
        width: imagepopup.implicitWidth.valueOf() > parent.width.valueOf() ? parent.width.valueOf() - 200 : imagepopup.implicitWidth.valueOf()
        height: imagepopup.implicitHeight.valueOf() > parent.height.valueOf() ? parent.height.valueOf() - 200 : imagepopup.implicitHeight.valueOf()
        modal: true
        focus: true
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem:
            Image {
            id: imagepopup
            height: parent.height.valueOf()
            width: parent.width.valueOf()
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            layer.enabled: true
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    imagecheck.close();
                }
            }
        }
    }



    Popup {
        id: changepopup
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
                text: qsTr("Изменение параметров беседы")
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
                anchors.rightMargin: 20
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
                id: buttonChangeConv
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 15
                width: 70
                height: 25
                contentItem: Label{
                    text: qsTr("Изменить")
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
                    manager.changeChatData(conv_name.text, id_conv.valueOf())
                    changepopup.close()
                    fillNeaded()
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
                    changepopup.close()
                }
            }
        }
    }
    Drawer {
        id: drawer
        width: window.width * 0.4
        height: window.height
        modal: false
        dragMargin: 0
        edge: Qt.RightEdge
        ColumnLayout{
            anchors.fill: parent
            anchors.topMargin: 5
            Rectangle{
                id: recta
                Layout.fillWidth: true
                Layout.bottomMargin: 5
                height: 60
                radius: 10
                Layout.margins: 2
                color: mouse.containsMouse ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                Rectangle{
                    id: rect
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: parent.height.valueOf() - 4
                    anchors.margins: 2
                    radius: 50
                    Image {
                        id: image
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: parent
                        }
                    }
                }
                Label{
                    id: convName
                    wrapMode: Text.Wrap
                    font.pointSize: 10
                    color: colorButtonText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: rect.right
                    anchors.right: parent.right
                    width: parent.width.valueOf() - (parent.height.valueOf() + 20)
                    anchors.leftMargin: 10
                    verticalAlignment: "AlignVCenter"
                }

                MouseArea{
                    id: mouse
                    enabled: isCreator
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: isCreator? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        changepopup.open()
                    }
                }
            }


            Label{
                id: users
                font.pointSize: 10
                color: colorFieldText
                Layout.fillWidth: true
                text: "Участники беседы:"
                verticalAlignment: "AlignVCenter"
            }

            Flickable{
                Layout.fillHeight: true
                Layout.fillWidth: true
                ListView{
                    id: convUsers
                    anchors.fill: parent
                    spacing: 10
                    clip: true
                    model: manager.getUsersForConv(id_conv.valueOf())

                    delegate: Rectangle{
                        height: 60
                        radius: 10
                        color: mousearea.containsMouse ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                        anchors.margins: 2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Rectangle {
                            id: imagerect
                            width: 58
                            height: 58
                            radius: 25
                            anchors.margins: 2
                            anchors.top: parent.top
                            anchors.left: parent.left
                            Image {
                                id: imageuser
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
                            anchors.leftMargin: 10
                            spacing: -1
                            Label{
                                id: llabel
                                text: model.last_name
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 9
                                color: colorButtonText
                            }
                            Label{
                                id: flabel
                                text: model.first_name
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 9
                                color: colorButtonText
                            }
                            Label{
                                id: olabel
                                text: model.otch
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 9
                                color: colorButtonText
                            }
                            Label{
                                id: elabel
                                text: model.email
                                verticalAlignment: "AlignVCenter"
                                font.pointSize: 8
                                color: colorButtonText
                            }
                        }

                        MouseArea{
                            id: mousearea
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(model.id_user != manager.getCurrentUserId()){
                                    stack.id = model.id_user
                                    stack.push(userpage)
                                }
                                else{
                                    mainstackView.sourceComponent = currentUserPage
                                }
                                drawer.close()
                            }
                        }
                        Button{
                            visible: isCreator && model.id_user != manager.getCurrentUserId()
                            id: buttonDelete
                            anchors.bottom: parent.bottom
                            anchors.top:  parent.top
                            HoverHandler{ cursorShape: Qt.PointingHandCursor }
                            anchors.right: parent.right
                            width: 50
                            height: 50
                            contentItem: Label{
                                text: qsTr("Удалить")
                                font.pointSize: 8
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
                                manager.deleteUserFromConv(model.id_chat_user)
                            }
                        }
                    }

                }
            }
            Button{
                id: buttonAddUsers
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                Layout.fillWidth: true
                height: 50
                contentItem: Label{
                    text: qsTr("Добавить пользователей в беседу")
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    Layout.fillHeight: true
                    implicitWidth: 100
                    radius: 5
                }
                onClicked: {
                    stack.push(addUser)
                    drawer.close()
                }
            }
            MenuSeparator{
                Layout.fillWidth: true
            }
            Button{
                id: buttonExit
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                Layout.fillWidth: true
                height: 50
                contentItem: Label{
                    text: qsTr("Выйти из беседы")
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    Layout.fillHeight: true
                    implicitWidth: 100
                    radius: 5
                }
                onClicked: {
                    drawer.close()
                    manager.exitConv(id_conv.valueOf())
                    stack.pop()
                }
            }
        }
    }
    Rectangle{
        anchors.fill: parent
        anchors.leftMargin: parent.width.valueOf() / 10
        anchors.rightMargin: parent.width.valueOf() / 10
        color: colorSideBackGround

        ListView{
            id: messages
            property bool complete: false
            ScrollBar.vertical: ScrollBar{id:scroll
                property bool fetchMore: true
                property bool fetchEnabled: false
            onPositionChanged: {
                if (scroll.position < 0.1 && fetchMore && messages.complete && fetchEnabled){
                    fetchMore = manager.fetchMessageModel(id_conv.valueOf())
                }
            }
            }
            Component.onCompleted: {
                messages.positionViewAtEnd()
                scroll.position = 1
                complete = true
            }
            property bool isScrollAtBottom: true
            onCountChanged: {
                if (isScrollAtBottom)
                    positionViewAtEnd();
            }
            onContentYChanged: {
                isScrollAtBottom = atYEnd;
                if (atYEnd)
                    positionViewAtEnd()
            }
            onContentHeightChanged: {
                if (isScrollAtBottom)
                    positionViewAtEnd();
                scroll.fetchEnabled = true
            }
            anchors.fill: parent
            anchors.bottomMargin: 145
            model: manager.getMessages(id_conv.valueOf())
            spacing: 25
            clip: true
            delegate: Rectangle{
                color: colorSideBackGround
                property int idMessage: model.id_message
                property bool isSticker: model.is_sticker == "true" ? true : false
                width: parent.width.valueOf()
                implicitHeight: childrenRect.height.valueOf() + 10
                Rectangle{
                    id: userdata
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    anchors.rightMargin: 100
                    radius: 10
                    height: 50
                    color: listmouse.containsMouse ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    RowLayout{
                        id: listrow
                        anchors.fill: parent
                        Rectangle {
                            id: listimagerect
                            width: 48
                            height: 48
                            radius: 25
                            anchors.margins: 2
                            Layout.alignment: Qt.AlignLeft
                            Image {
                                id: listimageuser
                                source: model.file_content_imagescaled == ""?  "defaultIcom.png" : manager.getImageBytes(model.file_content_imagescaled)
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: listimagerect
                                }

                            }
                        }
                        Label{
                            Layout.alignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            id: userfio
                            text: model.last_name
                            verticalAlignment: "AlignVCenter"
                            horizontalAlignment: "AlignLeft"
                            font.pointSize: 16
                            color: colorButtonText
                        }

                    }
                    MouseArea{
                        id: listmouse
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(model.id_user != manager.getCurrentUserId()){
                                stack.id = model.id_user
                                stack.push(userpage)
                            }
                            else{
                                mainstackView.sourceComponent = currentUserPage
                            }
                        }
                    }
                }
                Label{
                    anchors.top: userdata.top
                    anchors.bottom: userdata.bottom
                    anchors.left: userdata.right
                    width: 30
                    id: date
                    text: model.date_message
                    verticalAlignment: "AlignVCenter"
                    font.pointSize: 8
                    color: colorFieldText
                }
                RowLayout{
                    visible: isSticker
                    anchors.top: userdata.bottom
                    anchors.left: userdata.left
                    anchors.right: userdata.right
                    height: 100
                    Rectangle {
                        id: stickerimagerect
                        visible:  isSticker
                        width: 75
                        height: 75
                        radius: 10
                        anchors.margins: 10
                        anchors.leftMargin: 20
                        Image {
                            id: stickerimageuser
                            source: isSticker? model.content_message : ""
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: stickerimagerect
                            }
                        }
                    }
                    Item{
                        Layout.fillWidth: true
                    }
                }
                TextArea{
                    id: contentlabel
                    visible: !isSticker
                    anchors.top: userdata.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    font.pointSize: 14
                    color: colorFieldText
                    text: model.content_message
                    wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                    selectByMouse: true
                    selectByKeyboard: true
                    readOnly: true
                }
                ListView{
                    id: filesMessage
                    visible: !isSticker
                    anchors.top: contentlabel.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: contentHeight.valueOf()
                    model: !isSticker? manager.getMessageFiles(idMessage.valueOf()) : ""
                    spacing: 10
                    anchors.margins: 10
                    clip: true
                    delegate: Rectangle{
                        height: 100
                        width: parent.width.valueOf()
                        color: colorButtonBackGround
                        radius: 40
                        Image {
                            visible: model.file_content_imagescaled == ""? false : true
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.margins: 10
                            anchors.leftMargin: 30
                            id: fileimageuser
                            source:  manager.getImageBytes(model.file_content_imagescaled)
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            MouseArea{
                                id: imagemouse
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    imageId = model.id_files_message
                                    imagecheck.open()
                                }
                            }
                        }
                        Label{
                            anchors.fill: parent
                            width: 30
                            text: model.file_name + '.' + model.file_extension
                            verticalAlignment: "AlignVCenter"
                            font.pointSize: 14
                            anchors.rightMargin: 35
                            wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                            color: colorButtonText
                            horizontalAlignment: "AlignHCenter"

                        }
                        Button{
                            id: buttonDownload
                            anchors.bottom: parent.bottom
                            anchors.top:  parent.top
                            anchors.right: parent.right
                            HoverHandler{ cursorShape: Qt.PointingHandCursor }
                            width: 80
                            height: 50
                            Image{
                                source: "downloadIcon.png"
                                anchors.centerIn: parent
                                width: 30
                                height: 30
                                fillMode: Image.PreserveAspectFit
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
                                savefileDialog.idFile = model.id_files_message
                                savefileDialog.currentFile = StandardPaths.writableLocation(StandardPaths.DownloadLocation) + "/" + model.file_name + '.' + model.file_extension
                                savefileDialog.defaultSuffix = model.file_extension
                                savefileDialog.open()
                            }
                        }
                    }

                }

            }



        }
        Rectangle{
            id: filesRect
            anchors.bottom: row.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 65
            anchors.margins: 0
            border.color: colorButtonBackGround
            border.width: 1
            Popup {
                id: stickerspopup
                width: parent.width.valueOf()
                padding: 0
                height: 65
                anchors.centerIn: filesRect
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                ListView{
                    id: stickers
                    anchors.fill: parent
                    anchors.margins: 1
                    model: manager.getStickers()
                    ScrollBar.horizontal: ScrollBar{ orientation: "Horizontal"}
                    spacing: 8
                    clip: true
                    orientation: Qt.Horizontal
                    delegate: Rectangle{
                        width: 60
                        height: parent.height.valueOf()
                        color: stickermouse.containsMouse ? Qt.darker(colorSideBackGround, 1.2) : colorSideBackGround
                        Rectangle {
                            id: stickerselectrect
                            width: 40
                            height: 40
                            radius: 10
                            anchors.margins: 10
                            anchors.leftMargin: 20
                            anchors.centerIn: parent
                            Image {
                                id: stickerimage
                                source:  model.source
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: stickerselectrect
                                }

                            }
                            MouseArea{
                                id: stickermouse
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    manager.sendSticker(id_chat_user.valueOf(), model.source)
                                    stickerspopup.close()
                                }
                            }
                        }

                    }

                }
            }
            ListView{
                id: files
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2
                orientation: Qt.Horizontal
                clip: true
                ScrollBar.horizontal: ScrollBar{ orientation: "Horizontal"}
                delegate: Rectangle{
                    height: parent.height.valueOf()
                    width: 130
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: colorSideBackGround
                    Label{
                        anchors.fill: parent
                        anchors.rightMargin: 35
                        color: colorFieldText
                        text: model.filename
                        font.pointSize: 8
                        horizontalAlignment: "AlignHCenter"
                        verticalAlignment: "AlignVCenter"
                        wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    }
                    Button{
                        id: buttonDeleteFile
                        anchors.bottom: parent.bottom
                        anchors.top:  parent.top
                        anchors.right: parent.right
                        HoverHandler{ cursorShape: Qt.PointingHandCursor }
                        width: 30
                        height: parent.height.valueOf()
                        contentItem: Label{
                            text: "✖"
                            color: colorButtonText
                            anchors.fill: parent
                            horizontalAlignment: "AlignHCenter"
                            verticalAlignment: "AlignVCenter"
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                                 (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                            width: 30
                            height: parent.height.valueOf()
                            radius: 5
                        }
                        onClicked: {
                            manager.deleteFile(model.id_file)
                        }
                    }
                }
            }
        }

        RowLayout{
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 80
            spacing: -1

            Button{
                id: buttonAdd
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                width: 80
                Layout.fillHeight: true
                contentItem: Label{
                    text: "📎"
                    font.pointSize: 20
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    Layout.fillHeight: true
                    implicitWidth: 80
                    radius: 5
                }
                onClicked: {
                    filesDialog.open()
                }
            }
            ScrollView{
                Layout.fillWidth: true
                implicitHeight: 80
                contentHeight: content.height.valueOf()
                TextArea{
                    id: content
                    property bool isClearNeeded: false
                    Layout.fillWidth: true; implicitHeight: 80
                    background: Rectangle { Layout.fillWidth: true; implicitHeight: 80; border.color: colorButtonBackGround; border.width: 1; radius: 5}
                    color: colorFieldText
                    placeholderText: qsTr("Напишите сообщение...")
                    font.pointSize: 12
                    wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                    selectByMouse: true
                    Keys.onPressed: {
                        if (((event.key == Qt.Key_Enter) || event.key == Qt.Key_Return) && !(event.modifiers & Qt.ShiftModifier))
                        {
                            if(manager.sendMessage(content.text, id_chat_user.valueOf()))
                            {
                                manager.resetFileSend()
                                files.model = manager.getFilesSend()
                                content.text = ""
                                isClearNeeded = true
                            }
                            else{
                                isClearNeeded = false
                            }
                        }
                    }
                    Keys.onReleased: {
                        if(isClearNeeded && ((event.key == Qt.Key_Enter) || event.key == Qt.Key_Return) && !(event.modifiers & Qt.ShiftModifier)){
                            content.text = ""
                        }
                    }
                    onLengthChanged: {
                        if (length > 1000){
                            var cursor = content.cursorPosition
                            if (cursor > 1000){
                                cursor = 1000
                            }
                            errorOcured(qsTr("Длина сообщение не должна превышать 1000 символов!"))
                            content.text = content.text.substring(0, 1000)
                            content.cursorPosition = cursor.toString()
                        }
                    }
                }
            }
            Button{
                id: buttonSticker
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                width: 100
                Layout.fillHeight: true
                contentItem: Label{
                    text: "🙂"
                    font.pointSize: 24
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    Layout.fillHeight: true
                    implicitWidth: 100
                    radius: 5
                }
                onClicked: {
                    if(!stickerspopup.visible)
                        stickerspopup.open()
                }
            }
            ToolSeparator{
                Layout.fillHeight: true
            }
            Button{
                id: buttonSend
                HoverHandler{ cursorShape: Qt.PointingHandCursor }
                width: 100
                Layout.fillHeight: true
                contentItem: Label{
                    text: qsTr("Отправить")
                    color: colorButtonText
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                background: Rectangle {
                    anchors.fill: parent
                    color: parent.down ? Qt.darker(colorButtonBackGround, 1.2) :
                                         (parent.hovered ? Qt.lighter(colorButtonBackGround, 1.2) : colorButtonBackGround)
                    Layout.fillHeight: true
                    implicitWidth: 100
                    radius: 5
                }
                onClicked: {
                    if(manager.sendMessage(content.text, id_chat_user.valueOf()))
                    {
                        manager.resetFileSend()
                        files.model = manager.getFilesSend()
                        content.text = ""
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

    FileDialog {
        id: savefileDialog
        property int idFile: -1
        title: qsTr("Please choose a folder for file")
        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)
        Component.onCompleted: {
            savefileDialog.fileMode = 2;
        }
        onAccepted: {
            manager.saveFile(savefileDialog.file, idFile.valueOf())
        }
    }

    FileDialog {
        id: filesDialog
        title: qsTr("Please choose files")
        fileMode: FileDialog.OpenFiles
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        Component.onCompleted: {
            filesDialog.fileMode = 1;
        }
        onAccepted: {
            console.log(filesDialog.fileMode.valueOf())
            manager.addToFiles(filesDialog.files)
            files.model =  manager.getFilesSend()
        }
    }



}
