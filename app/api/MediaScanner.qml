/*
 * Copyright (C) 2018 The Qt Company Ltd.
 * Copyright (C) 2017 Konsulko Group
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtWebSockets 1.0

WebSocket {
    id: root
    active: true
    url: bindingAddress

    property string statusString: "waiting..."
    property string apiString: "mediascanner"
    property var verbs: []
    property string payloadLength: "9999"

    readonly property var msgid: {
        "call": 2,
        "retok": 3,
        "reterr": 4,
        "event": 5
    }

    signal added(var media)
    signal removed(var index)

    property var cache: []
    function add(files) {
        for (var i = 0; i < files.length; i++) {
            var media = files[i]

            if (cache.indexOf(media.path) < 0) {
                root.added(media)
                cache.push(media.path)
            }
        }
    }

    function remove(prefix) {
        for (var i = cache.length - 1; i > -1; i--) {
            var media = cache[i]
            if (media.substr(0, prefix.length) === prefix) {
                root.removed(i)
                cache.splice(i, 1)
            }
        }
    }

    onTextMessageReceived: {
        console.debug("Raw response: " + message)
        var json = JSON.parse(message)
        var request = json[2].request
        var response = json[2].response
//        console.debug("response: " + JSON.stringify(response))
        switch (json[0]) {
            case msgid.call:
                break
            case msgid.retok:
                root.statusString = request.status
                var verb = verbs.shift()
                if (verb === "media_result") {
                    root.add(response.Media)
                }
                break
            case msgid.reterr:
                root.statusString = "Bad return value, binding probably not installed"
                var verb = verbs.shift()
                break
            case msgid.event:
                var payload = JSON.parse(JSON.stringify(json[2]))
                var event = payload.event
                if (event == "mediascanner/media_added") {
                    console.debug("Media playlist is updated")
                    root.add(json[2].data.Media)
                } else if (event == "mediascanner/media_removed") {
                    root.remove(json[2].data.Path)
                }
                break
        }
    }

    onStatusChanged: {
        switch (status) {
        case WebSocket.Open:
            console.debug("onStatusChanged: Open")
            sendSocketMessage("subscribe", { value: "media_added" })
            sendSocketMessage("subscribe", { value: "media_removed" })
            sendSocketMessage("media_result", { type: 'video' })
            break
        case WebSocket.Error:
            root.statusString = "WebSocket error: " + root.errorString
            break
        }
    }

    function sendSocketMessage(verb, parameter) {
        var requestJson = [ msgid.call, payloadLength, apiString + '/'
        + verb, parameter ]
        console.debug("sendSocketMessage: " + JSON.stringify(requestJson))
        verbs.push(verb)
        sendTextMessage(JSON.stringify(requestJson))
    }
}
