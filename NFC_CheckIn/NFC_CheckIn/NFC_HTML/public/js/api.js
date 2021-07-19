const tableID = 'checkIn'
const title = unescape(urlParameters()['path'])
const checkInPath = `/@NFC/CheckIn/${title}`
const infoPath = `/@NFC/MeetingInformation/${title}`
const type = 'value'

window.onload = init

// 初始設定
function init() {
    checkInInfoReader()
}

// https://<host>/?path=2019-09-27 18:00:00 +0000
function checkInInfoReader() {

    firebase.database().ref(infoPath).once(type, snapshot => {

        const meetingInfos = snapshot.val()
        const meeting = meetingInfos.name

        firebase.database().ref(checkInPath).orderByChild("time").on(type, snapshot => {

            let tableInfo = `<caption>${meeting}</caption>`
            tableInfo += '<tr><th>姓名</th><th>時間</th></tr>'

            snapshot.forEach((item) => {

                const info = item.val()
                const localeTime = localeStringTime(info.time, 'zh-TW')

                tableInfo += `<tr><td>${info.name}</td><td>${localeTime}</td></tr>`
            })

            document.getElementById(tableID).innerHTML = tableInfo
        })
    })
}

/// https://<host>/?path=2019-09-27 18:00:00 +0000 => ['path': 2019-09-27 18:00:00 +0000]
function urlParameters() {

    let parameterss = {}

    window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
        parameterss[key] = value
    })

    return parameterss
}

/// 2019-09-27 18:00:00 +0000 => 2019/09/27 18:00:00 +0000 => 2019/9/28 上午2:00:00
function localeStringTime(dateString, locale) {

    const _dateString = dateString.replace(/-/g, '/')
    const timestamap = Date.parse(_dateString)
    const date = new Date(timestamap)

    return date.toLocaleString(locale)
}
