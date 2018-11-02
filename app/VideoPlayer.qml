/*
 * Copyright (C) 2018 The Qt Company Ltd.
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtMultimedia 5.6
import AGL.Demo.Controls 1.0
import 'api' as API

ApplicationWindow {
    id: root

    API.MediaScanner {
        id: scanner
        url: bindingAddress

        property var titles: Object
        onAdded: {
            playlist.addItem(media.path)
            titles[media.path] = media.title
        }
        onRemoved: {
            playlist.removeItem(index)
        }
    }

    MediaPlayer {
        id: player
        audioRole: MediaPlayer.MusicRole
        autoLoad: true
        playlist: playlist
        function time2str(value) {
            return Qt.formatTime(new Date(value), 'mm:ss')
        }
        onPositionChanged: slider.value = player.position
    }

    Playlist {
        id: playlist
        playbackMode: Playlist.Loop

//        PlaylistItem { source: 'file:///home/root/Videos/Qt_Mashup_DO_NOT_MODIFY.mp4' }
//        PlaylistItem { source: 'file:///home/root/Videos/Qt_is_everywhere-071116.mp4' }
    }

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 1080
            clip: true

            VideoOutput {
                source: player
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    color: 'black'
                    opacity: 0.75
                    z: -1
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        controls.visible = !controls.visible;
                    }
                }

                Item {
                    id: controls
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    visible: false
                    height: 240
                    z: 100

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Row {
                                spacing: 20
                                ToggleButton {
                                    id: random
                                    offImage: './images/AGL_MediaPlayer_Shuffle_Inactive.svg'
                                    onImage: './images/AGL_MediaPlayer_Shuffle_Active.svg'
                                }
                                ToggleButton {
                                    id: loop
                                    offImage: './images/AGL_MediaPlayer_Loop_Inactive.svg'
                                    onImage: './images/AGL_MediaPlayer_Loop_Active.svg'
                                }
                            }
                            ColumnLayout {
                                anchors.fill: parent
                                Label {
                                    id: title
                                    Layout.alignment: Layout.Center
                                    text: player.metaData.title ? player.metaData.title : ''
                                    horizontalAlignment: Label.AlignHCenter
                                    verticalAlignment: Label.AlignVCenter
                                }
                                Label {
                                    id: artist
                                    Layout.alignment: Layout.Center
                                    text: player.metaData.author ? player.metaData.author : ''
                                    horizontalAlignment: Label.AlignHCenter
                                    verticalAlignment: Label.AlignVCenter
                                    font.pixelSize: title.font.pixelSize * 0.6
                                }
                            }
                        }
                        Slider {
                            id: slider
                            Layout.fillWidth: true
                            to: player.duration
                            Label {
                                id: position
                                anchors.left: parent.left
                                anchors.bottom: parent.top
                                font.pixelSize: 24
                                text: player.time2str(player.position)
                            }
                            Label {
                                id: duration
                                anchors.right: parent.right
                                anchors.bottom: parent.top
                                font.pixelSize: 24
                                text: player.time2str(player.duration)
                            }
                            onPressedChanged: player.seek(value)
                        }
                        RowLayout {
                            Layout.fillHeight: true
                            Item { Layout.fillWidth: true }
                            ImageButton {
                                offImage: './images/AGL_MediaPlayer_BackArrow.svg'
                                onClicked: playlist.previous()
                            }
                            ImageButton {
                                id: play
                                offImage: './images/AGL_MediaPlayer_Player_Play.svg'
                                onClicked: player.play()
                                states: [
                                    State {
                                        when: player.playbackState === MediaPlayer.PlayingState
                                        PropertyChanges {
                                            target: play
                                            offImage: './images/AGL_MediaPlayer_Player_Pause.svg'
                                            onClicked: player.pause()
                                        }
                                    }
                                ]
                            }
                            ImageButton {
                                offImage: './images/AGL_MediaPlayer_ForwardArrow.svg'
                                onClicked: playlist.next()
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }
        }
        Item {
            id: playlistArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 407
            ListView {
                anchors.fill: parent
                clip: true
                header: Label {
                    x: 50
                    text: 'PLAYLIST'
                    opacity: 0.5
                }
                model: playlist
                currentIndex: playlist.currentIndex

                delegate: MouseArea {
                    id: delegate
                    width: ListView.view.width
                    height: ListView.view.height / 4
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 50
                        anchors.rightMargin: 50
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label {
                                Layout.fillWidth: true
                                text: scanner.titles[model.source] ? scanner.titles[model.source] : model.source.toString().split('/').reverse()[0]
                            }
                        }
                        Label {
                            text: player.time2str(model.duration)
                            color: '#66FF99'
                            font.pixelSize: 32
                        }
                    }
                    property var m: model
                    onClicked: {
                        playlist.currentIndex = model.index
                        player.play()
                    }
                }

                highlight: Rectangle {
                    color: 'white'
                    opacity: 0.25
                }
            }
        }
    }

    
    function changeArea(area) {
        if (area === 'normal') {
            playlistArea.visible = true;
        } else {
            playlistArea.visible = false;
        }
    }
}
