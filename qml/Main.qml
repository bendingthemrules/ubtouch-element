import QtQuick 2.7
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtWebEngine 1.7

MainView {
    id: root
    objectName: "mainView"
    applicationName: "nl.btr.element"

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
            sourceCode: `
                const css =
                    '.mx_Dialog{max-width:100vw}.mx_IntegrationManager .mx_Dialog,.mx_Dialog .mx_Dialog_fixedWidth,.mx_ContextualMenu,.mx_EmojiPicker{width:calc(100vw - 56px)!important}div.sc_Body{padding-left:0!important;padding-right:0!important}.mx_TabbedView_tabPanel{margin-left:0!important}.mx_ContextualMenu_wrapper{top:0!important;left:0!important}.mx_ContextualMenu{position:fixed!important;right:initial;left:50%!important;top:50%!important;transform:translate(-50%,-50%)}.mx_ContextualMenu>div:nth-child(2) *,.mx_IconizedContextMenu,.mx_RoomSublist_contextMenu,.mx_CompleteSecurityBody{max-width:100%!important}#mx_SpotlightDialog_keyboardPrompt{display:none}.mx_RightPanel_ResizeWrapper{position:absolute!important;right:0!important;padding-top:0!important}.mx_TabbedView_tabsOnLeft,.mx_TabbedView .mx_TabbedView_tabsOnLeft{position:initial!important;display:initial!important}.mx_TabbedView_tabsOnLeft{position:initial!important}.mx_TabbedView_tabLabels{display:flex;flex-wrap:wrap;width:initial!important;max-width:initial!important;position:initial!important}.mx_SettingsTab .mx_SidebarUserSettingsTab{width:100%!important;min-width:initial!important;padding:0!important}.mx_TabbedView_tabsOnLeft .mx_TabbedView_tabPanel{margin-left:0!important}.mx_AutoHideScrollbar .mx_TabbedView_tabPanelContent>*{min-width:initial!important;padding:0!important}.mx_RoomSettingsDialog .mx_TabbedView .mx_SettingsTab,.mx_SpacePreferencesDialog .mx_TabbedView .mx_SettingsTab,.mx_SpaceSettingsDialog .mx_TabbedView .mx_SettingsTab,.mx_UserSettingsDialog .mx_TabbedView .mx_SettingsTab{min-width:initial!important;padding:0!important}.mx_SettingsTab>*,.mx_SettingsTab_section>*{margin-right:0!important}.mx_MatrixChat .mx_HomePage_default_wrapper>div:nth-child(1){width:100vw!important;padding:0 2rem!important;box-sizing:border-box}.mx_MatrixChat .mx_HomePage_default_buttons{flex-wrap:wrap;justify-content:center}.mx_HomePage_default .mx_HomePage_default_buttons .mx_AccessibleButton:before{left:50%!important;transform:translate(-50%)}.mx_HomePage_default_wrapper .mx_Tooltip{display:none!important}.mx_CompleteSecurityBody{width:100vw!important}';

                const head = document.head || document.getElementsByTagName('head')[0];
                const style = document.createElement('style');

                head.appendChild(style);
                style.appendChild(document.createTextNode(css));

                let interval;
                let serverBar;

                function advancedClose(e) {
                const spaceButtons = document.querySelectorAll('.mx_RoomTile');

                // if clicked on settings/notifications
                if (
                    e.target.classList.contains('mx_RoomTile_menuButton') ||
                    e.target.classList.contains('mx_RoomTile_notificationsButton')
                ) {
                    return;
                }

                // test if clicked chat button
                for (const button of spaceButtons) {
                    if (button.contains(e.target)) {
                    hide();

                    addBurger();
                    interval = setInterval(addBurger, 100);
                    return;
                    }
                }

                e.target;
                }

                function show() {
                serverBar.style.right = '0';
                }

                function hide() {
                serverBar.style.right = '100vw';
                }

                function addBurger() {
                const chatHeader = document.querySelector(
                    '.mx_MatrixChat header .mx_RoomHeader_wrapper'
                );

                const chatHeaderFirst = chatHeader?.firstChild;
                if (!chatHeaderFirst || document.querySelector('.openMenu')) {
                    return;
                }

                const burgerMenu = document.createElement('div');
                burgerMenu.addEventListener('click', show);
                burgerMenu.ariaLabel = 'Open menu';
                burgerMenu.role = 'button';
                burgerMenu.classList = 'mx_AccessibleButton openMenu';
                burgerMenu.style =
                    'display:flex;justify-content:center;align-items:center;margin:12px auto 12px 1rem;color:#949494;min-width:32px;min-height:32px;mask:none';
                burgerMenu.innerHTML =
                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>';

                chatHeaderFirst.parentNode.insertBefore(burgerMenu, chatHeaderFirst);

                clearInterval(interval);
                }

                initInterval = setInterval(() => init(), 300);
                function init() {
                const a = document.querySelector(
                    '.mx_MatrixChat div.mx_ResizeHandle.mx_ResizeHandle_horizontal'
                );
                serverBar = document.querySelector(
                    '.mx_MatrixChat .mx_LeftPanel_outerWrapper'
                );
                const c = document.querySelector('.mx_MatrixChat nav.mx_LeftPanel_wrapper');

                if (!a || !serverBar || !c) {
                    return;
                }

                a.style.display = 'none';
                c.style.background = '#5c5c5c';

                if (document.querySelector('.openMenu')) {
                    return;
                }

                addBurger();

                if (serverBar.getAttribute('listener') !== 'true') {
                    console.log('adding listener');
                    serverBar.addEventListener('click', advancedClose);
                    serverBar.style =
                    'position:absolute;top:0;width:100vw;max-width:100vw;height:100vh;z-index:1000;right:100vw;transition:right 0.2s ease';
                    serverBar.setAttribute('listener', 'true');
                }
            }
            `
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
