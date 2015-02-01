import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2
import Controller 1.0

Overlay {
    id: root
    property QtObject task: null
    property string prettyDueDateString: task ? task.prettyDueDateString : ""

    contentHeight: height - contentTopMargin - _style.pageMargin - _style.marginSmall
    centerPopup: false
    contentItem:
    Item {
        anchors.fill: parent
        Column {
            id: column
            spacing: 10 * _controller.dpiFactor
            height: childrenRect.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10 * _controller.dpiFactor
            anchors.rightMargin: 10 * _controller.dpiFactor

            Item {
                height: 20 * _controller.dpiFactor
                width: parent.width
                Text {
                    id: summaryText
                    text: qsTr("Summary") + ":"
                    anchors.left: parent.left
                    font.pixelSize: 13 * _controller.dpiFactor
                }

                TextInput {
                    id: textInput
                    focus: true
                    font.pixelSize: 14 * _controller.dpiFactor
                    anchors.left: summaryText.right
                    anchors.leftMargin: 10 * _controller.dpiFactor
                    anchors.verticalCenter: parent.verticalCenter
                    width: 0.70 * parent.width
                    text: root.task ? root.task.summary : ""
                    onAccepted: {
                        root.accept()
                    }
                    onVisibleChanged: {
                        textInput.forceActiveFocus()
                    }
                }

                Rectangle {
                    height: 1 * _controller.dpiFactor
                    width: textInput.width
                    anchors.top: textInput.bottom
                    anchors.left: textInput.left
                    color: "black"
                }
            }

            Row {
                height: 20 * _controller.dpiFactor
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 5 * _controller.dpiFactor
                FontAwesomeIcon {
                    id: dueDateExpanded
                    anchors.top: titleText.top
                    anchors.topMargin: 2 * _controller.dpiFactor
                    property bool expanded: root.prettyDueDateString !== ""
                    size: 20
                    text: expanded ? "\uf073" : "\uf133"
                    color: _style.regularTextColor
                    anchors.verticalCenter: undefined
                    onClicked: {
                        if (expanded) {
                            root.task.removeDueDate()
                            textInput.focus = true
                        } else {
                            root.task.dueDate = new Date()
                            calendar.focus = true
                        }
                    }
                }
                Text {
                    id: dueDateText

                    function dateString()
                    {
                        if (root.prettyDueDateString) {
                            return root.task.isOverdue ? root.task.dueDateString : root.prettyDueDateString
                        } else {
                            return qsTr("Not set")
                        }
                    }

                    text: qsTr("Due date") + " (" + dateString() + ")"
                    font.pixelSize: 13 * _controller.dpiFactor
                }
            }

            Column {
                visible: dueDateExpanded.expanded
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40 * _controller.dpiFactor
                spacing: 2 * _controller.dpiFactor
                Calendar {
                    id: calendar
                    width: parent.width
                    height: 230 * _controller.dpiFactor
                    minimumDate: new Date()
                    selectedDate: (root.task && root.task.dueDateString) ? root.task.dueDate : new Date()

                    onClicked: {
                        root.task.dueDate = date
                        calendar.focus = true
                    }

                    Keys.onEnterPressed: {
                        root.task.dueDate = selectedDate
                        root.accept()
                    }
                    Keys.onReturnPressed: {
                        root.task.dueDate = selectedDate
                        root.accept()
                    }

                    style: CalendarStyle {
                        navigationBar: Rectangle {
                            height: 25 * _controller.dpiFactor

                            color: "#E9E9E9"
                            FontAwesomeIcon {
                                id: iconLeft
                                text: "\uf0a8"
                                anchors.left: parent.left
                                anchors.leftMargin: 15 * _controller.dpiFactor
                                height: parent.height
                                z: 2
                                color: "black"
                                onClicked: {
                                    control.showPreviousMonth()
                                }
                            }
                            Text {
                                height: 25 * _controller.dpiFactor
                                anchors.left: iconLeft.right
                                anchors.right: iconRight.left
                                text: styleData.title
                                font.bold: true
                                font.pixelSize: 20 * _controller.dpiFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignBottom
                            }
                            FontAwesomeIcon {
                                id: iconRight
                                text: "\uf0a9"
                                anchors.right: parent.right
                                anchors.rightMargin: 15 * _controller.dpiFactor
                                height: parent.height
                                z: 2
                                color: "black"
                                onClicked: {
                                    control.showNextMonth()
                                }
                            }
                        }

                        dayOfWeekDelegate: Rectangle {
                            height: 25 * _controller.dpiFactor
                            Text {
                                text: Qt.locale().dayName(styleData.dayOfWeek, control.dayOfWeekFormat)
                                horizontalAlignment: Text.AlignHCenter
                                anchors.fill: parent
                                font.pixelSize: 14 * _controller.dpiFactor
                            }
                        }
                    }
                }

                Text {
                    text: qsTr("Task will be automatically moved to \"Today's queue\" at this date")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.Wrap
                    font.pixelSize: 12 * _controller.dpiFactor
                    color: "#444444"
                }
            }
        }

        PushButton {
            id: buttonOk
            text: qsTr("OK")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10 * _controller.dpiFactor
            onClicked: {
                root.accept()
            }
        }
    }

    function accept()
    {
        if (task && textInput.text)
            task.summary = textInput.text

        _controller.editTask(null, Controller.EditModeNone)
    }
}
