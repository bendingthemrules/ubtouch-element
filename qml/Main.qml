import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.PushNotifications 0.1
import QtWebEngine 1.7

MainView {
    id: root
    objectName: "mainView"
    applicationName: "nl.btr.element"

    PushClient {
        id: pushClient
        appId: "nl.btr.element_element"

        Component.onCompleted: {
            notificationsChanged.connect((msgs) => {
                console.log('GOT NOTIFICATION', msgs);
            });
            error.connect((err) => {
                console.log('GOT ERROR', err);
            });
        }
        onTokenChanged: { console.log("Got token", pushClient.token) } 
    }

    WebEngineView {
        id: webEngineView
        width: parent.width
        height: parent.height
        visible: false
        zoomFactor: 1
        anchors.fill: parent
        url: "https://app.element.io/"
        userScripts:  WebEngineScript {
            injectionPoint: WebEngineScript.DocumentReady
            sourceUrl: "qrc:/assets/payload.js"
        }
        onNewViewRequested: (request) => {
            Qt.openUrlExternally(request.requestedUrl);
        }
        onLoadProgressChanged: {
            progressBar.value = loadProgress
            if (loadProgress === 100) {
                visible = true;
            }
        }
        onFeaturePermissionRequested: {
            console.log("feature permission request", feature, securityOrigin)

            webEngineView.grantFeaturePermission(securityOrigin, feature, true);
        }
        onFileDialogRequested: function(request) {
            switch (request.mode)
            {
                case FileDialogRequest.FileModeOpen:
                    request.accepted = true;
                    var dialog = PopupUtils.open(Qt.resolvedUrl("FileDialog.qml"), this);
                    dialog.allowMultipleFiles = false;
                    dialog.accept.connect(request.dialogAccept);
                    dialog.reject.connect(request.dialogReject);
                    break;

                case FileDialogRequest.FileModeOpenMultiple:
                    request.accepted = true;
                    var dialog = PopupUtils.open(Qt.resolvedUrl("FileDialog.qml"), this);
                    dialog.allowMultipleFiles = true;
                    dialog.accept.connect(request.dialogAccept);
                    dialog.reject.connect(request.dialogReject);
                    break;

                case FilealogRequest.FileModeUploadFolder:
                case FileDialogRequest.FileModeSave:
                    request.accepted = false;
                    break;
            }
        }

        onNavigationRequested: (request) => {
            console.log("onNavigationRequested", request.url)
            if (request.url.toString().includes("/internal-registerUser")) {
                // ignore request
                request.action = WebEngineNavigationRequest.IgnoreRequest
                
                if (!pushClient.token) {
                    console.log("No push token yet, ignoring request")
                    return
                }
                // register push notifications
                const userID = request.url.toString().split("userID=")[1].split("&")[0]
                const accessToken = request.url.toString().split("accessToken=")[1].split("&")[0]
                const homeServer = request.url.toString().split("homeServer=")[1].split("&")[0]

                QClient.registerNotifications(userID, accessToken, homeServer, pushClient.token)
            }
        }
    }

    Connections {
        target: UriHandler
        onOpened: {
            console.log("Open from Webview UriHandler", uris)

            if (uris.length > 0) {
                console.log("clicked push message while in app")
                const roomId = uris[0].split("#")[1]
                webEngineView.url = `https://app.element.io/#/room/${roomId}`
            }               
        }
    }
    
    Connections {
        target: Qt.inputMethod

        onKeyboardRectangleChanged: {
            var newRect = Qt.inputMethod.keyboardRectangle
            var scale = (newRect.y + newRect.height) / root.height

            webEngineView.height = newRect.height == 0 
                ? root.height + 1
                : Math.ceil(newRect.y / scale);
        }
    }

    Rectangle {
        visible: !webEngineView.visible
        color: "#0DBD8B"
        anchors.fill: parent
    }

    Column {
        anchors.fill: parent
        visible: !webEngineView.visible
        
        Image {
            id: image
            width: 150
            height: 150 
            anchors.centerIn: parent
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            source: "qrc:/assets/loader.svg"
        }

        ProgressBar {
            id: progressBar
            value: 0
            minimumValue: 0
            maximumValue: 100
            anchors.top: image.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 30
        }
    }
}
