import QtQuick 2.0

Rectangle {
    id: root
    color: _style.queueBackgroundColor

    Loader {
        id: loader
        enabled: sourceComponent != null
        anchors.fill: parent
        objectName: "mainMobileLoader"
        sourceComponent: _controller.startupFinished ? Qt.createComponent("MainMobile.qml")
                                                     : null // Delayed loading
    }
}
