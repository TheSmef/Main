import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    id: window
    width: 800
    height: 800
    visible: true
    title: qsTr("Messenger")
    minimumWidth: 950
    minimumHeight: 500



    Connections{
        target: manager
        onWorkProcessError: {
            popuptext.text = error
            popup.open()
        }

    }

    Popup {
        id: popup
        anchors.centerIn: parent
        width: 500
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Rectangle {
            anchors.fill: parent
            color: colorMainBackGround
            Text {
                id: popuptext
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                anchors.fill: parent
                color: colorFieldText
                font.pixelSize: 14
            }
            Button{
                HoverHandler{
                    cursorShape: Qt.PointingHandCursor
                }
                id: buttonClose
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 15
                width: 40
                height: 25
                contentItem: Label{
                    text: qsTr("Ок")
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
                    popup.close()
                }
            }

        }
        onClosed: {
            popuptext.text = ""
        }
    }

    Component.onDestruction: {
        Settings.write("height", window.height);
        Settings.write("width", window.width);
        Settings.write("x", window.x);
        Settings.write("y", window.y);
    }

    Component.onCompleted: {
        window.height =  Settings.read("height");
        window.width =  Settings.read("width");
        window.x =  Settings.read("x");
        window.y =  Settings.read("y");
        manager.connectToServer()
        newAuthTrougthSettings(Settings.read("login"), Settings.read("password"))
    }

    property string colorMainBackGround: "#e9ecf1"
    property string colorSideBackGround: "#ffffff"
    property string colorButtonBackGround: "#597ba0"
    property string colorFieldText: "#486a8d"
    property string colorButtonText: "#ffffff"
    property bool drawerVisibility: false


    //methods
    signal newResetPassAuth(string password, string passwordRep, string passConfEmail, string email)
    onNewResetPassAuth: {
        if (password == passwordRep){
            if (manager.resetPassword(password, passConfEmail, email)){
                mainstackView.sourceComponent = convpage;
                drawerVisibility = true;
            }
        }
        else{
            errorOcured(qsTr("Введённые пароли не совпадают"))
        }
    }
    signal errorOcured(string error)
    onErrorOcured: {
        popuptext.text = error
        popup.open()
    }

    signal newResetPass()
    onNewResetPass: {
        mainstackView.sourceComponent = reset
    }
    signal newAuth(string login, string password)
    onNewAuth: {
        if(manager.authUser(login, password)){
            mainstackView.sourceComponent = convpage;
            drawerVisibility = true;
        }
    }
    signal newAuthTrougthSettings(string login, string password)
    onNewAuthTrougthSettings: {
        if(manager.authThroughtSettings(login, password)){
            mainstackView.sourceComponent = convpage;
            drawerVisibility = true;
        }
    }
    signal newReg(string lastname, string firstname, string otch, string login, string email, string password, string passwordRep, string emailCode)
    onNewReg: {
        if (password == passwordRep){
            if (manager.registrateNewUser(lastname, firstname, otch, login, email, password, emailCode)){
                mainstackView.sourceComponent = convpage;
                drawerVisibility = true;
            }
        }
        else{
            errorOcured(qsTr("Введённые пароли не совпадают"))
        }
    }
    signal newRegPush()
    onNewRegPush: {
        mainstackView.sourceComponent = reg;
    }
    signal newPushAuth()
    onNewPushAuth: {
        mainstackView.sourceComponent = auth;
    }

    color: colorMainBackGround


    header: ToolBar {
        contentHeight: toolButton.implicitHeight
        background: Rectangle{color: colorMainBackGround}



        ToolButton {
            HoverHandler{
                cursorShape: Qt.PointingHandCursor
            }
            id: toolButton
            visible: drawerVisibility


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

        Label {
            text: mainstackView.item.title
            anchors.centerIn: parent
            font.pointSize: 20
            height: 50
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            color: colorFieldText
            horizontalAlignment: "AlignHCenter"
        }

    }

    Drawer {
        id: drawer
        width: window.width * 0.3
        height: window.height


        dragMargin: 0



        Column {
            anchors.fill: parent
            spacing: 2
            ItemDelegate {
                id: first
                background: Rectangle{
                    color: first.hovered ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    radius: 10
                }

                width: parent.width
                contentItem: Text{
                    text: qsTr("Моя страница")
                    font.pointSize: 14
                    color: colorButtonText
                }
                MouseArea{
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainstackView.sourceComponent = currentUserPage
                        drawer.close()
                    }
                }

            }
            ItemDelegate {
                id: second
                background: Rectangle{
                    color: second.hovered ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    radius: 10
                }
                width: parent.width
                contentItem: Text{
                    text: qsTr("Беседы")
                    font.pointSize: 14
                    color: colorButtonText
                }
                MouseArea{
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainstackView.sourceComponent = convpage
                        drawer.close()
                    }
                }

            }
            ItemDelegate {
                id: third

                background: Rectangle{
                    color: third.hovered ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    radius: 10
                }
                width: parent.width

                contentItem: Text{
                    text: qsTr("Поиск пользователей")
                    font.pointSize: 14
                    color: colorButtonText
                }
                MouseArea{
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainstackView.sourceComponent = searchUserpage
                        drawer.close()
                    }
                }

            }
            ItemDelegate {
                id: fourth
                background: Rectangle{
                    color: fourth.hovered ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    radius: 10
                }
                width: parent.width
                contentItem: Text{
                    text: qsTr("Чёрный список")
                    font.pointSize: 14
                    color: colorButtonText
                }
                MouseArea{
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainstackView.sourceComponent = banUserPage
                        drawer.close()
                    }
                }
            }
            MenuSeparator{
                width: parent.width
            }
            ItemDelegate {
                id: fifth

                background: Rectangle{
                    color: fifth.hovered ? Qt.darker(colorButtonBackGround, 1.2) : colorButtonBackGround
                    radius: 10
                }
                width: parent.width
                contentItem: Text{
                    text: qsTr("Выход из аккаунта")
                    font.pointSize: 14
                    color: colorButtonText
                }
                MouseArea{
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        newPushAuth()
                        drawer.close()
                        manager.resetCurrentUserId()
                        drawerVisibility = false
                        Settings.write("login", "");
                        Settings.write("password", "");
                    }
                }
            }

        }
    }


    Loader {
        id: mainstackView
        sourceComponent:  auth
        anchors.fill: parent
    }
    Component{
        id:auth
        Autorization{
            id: authpage
        }
    }
    Component{
        id:reg
        Registration{
            id: regpage
        }
    }
    Component{
        id: reset
        ResetPassword{
            id: resetpass
        }
    }
    Component{
        id: convpage
        MessengerConversations{
            id: conv
        }
    }
    Component{
        id: searchUserpage
        SearchUser{
            id: searchUser
        }
    }
    Component{
        id: banUserPage
        BanList{
            id: banUser
        }
    }
    Component{
        id: currentUserPage
        CurrentUsersPage{
            id: currentUser
        }
    }


}
