import QtQuick 2.6
import Qt.labs.calendar 1.0
import QtQuick.Controls 1.4

MonthGrid {
    id: monthGrid
    property Item firstNextMonth: null
    property real offset: firstNextMonth ? (height - firstNextMonth.y) : 0
    property Item firstWeekDayNextMonth: null
    property real endOffset: firstWeekDayNextMonth ? (height - firstWeekDayNextMonth.y) : 0

    delegate: Item {
        implicitWidth: Math.max(dateDelegateMetrics.width, dateDelegateMetrics.height) * 2
        implicitHeight: width
        opacity: monthGrid.month === model.month ? 1.0 : 0.0
        onYChanged: {
            if (monthGrid.month < model.month || (monthGrid.month === Calendar.December && model.month === Calendar.January)) {
                if (model.day === 1) {
                    monthGrid.firstNextMonth = this
                }
                if (index % 7 && model.day >= 1 && model.day <= 7) {
                    monthGrid.firstWeekDayNextMonth = this
                }
            }
        }
        TextMetrics {
            id: dateDelegateMetrics
            text: "00"
            font.pointSize: 12
        }
        Column {
            anchors.centerIn: parent
            Text {
                color: (calendarComponent.month - 1) === model.month ? mainPalette.text : mainPalette.borderColor
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                font.bold: model.today
                text: model.day
                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    height: parent.height + 10
                    width: height
                    color: Qt.rgba(50/255.0, 215/255.0, 75/255.0, 1.0)
                    visible: calendarComponent.day === model.day && (calendarComponent.month - 1) === model.month
                    radius: 4
                }
            }
            Text {
                visible: model.day === 1
                color: "red"
                text: monthGrid.title.slice(0, 3).toUpperCase()
                font.pointSize: 12
            }
        }
    }
}