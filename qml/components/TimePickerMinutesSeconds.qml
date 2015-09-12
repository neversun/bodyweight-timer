/****************************************************************************************
** Original by:
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: timePickerMinutesSeconds

    property int minute
    property int second

    property date time: new Date(0,0,0,0, minute,second)
    property string timeText: _formatTime()

    property real _minuteWidth: Theme.itemSizeExtraSmall


    width: screen.sizeCategory > Screen.Medium ? Theme.itemSizeLarge*4 : Theme.itemSizeMedium*4
    height: width

    onSecondChanged: {
        second = (second < 0 ? 0 : (second > 59 ? 59 : second))

        if (mouse.changingProperty == 0) {
            var delta = (second - secondIndicator.value)
            secondIndicator.value += (delta % 60)
        }
    }

    onMinuteChanged: {
        minute = (minute < 0 ? 0 : (minute > 59 ? 59 : minute))

        if (mouse.changingProperty == 0) {
            var delta = (minute - minuteIndicator.value)
            minuteIndicator.value += (delta % 60)
        }
    }

    function _xTranslation(value, bound) {
        // Use sine to map range of 0-bound to the X translation of a circular locus (-1 to 1)
        return Math.sin((value % bound) / bound * Math.PI * 2)
    }

    function _yTranslation(value, bound) {
        // Use cosine to map range of 0-bound to the Y translation of a circular locus (-1 to 1)
        return Math.cos((value % bound) / bound * Math.PI * 2)
    }

    function _formatTime() { //TODO
        var date = new Date()
        date.setMinutes(timePicker.minute)
        date.setSeconds(timePicker.second)
        return Format.formatDate(date, Formatter.DurationShort)
    }

    ShaderEffect {
        anchors.fill: parent
        property size size: Qt.size(width, height)
        property real border: _minuteWidth / width
        fragmentShader: "
            uniform lowp vec2 size;
            uniform lowp float border;
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            void main() {
                float dist = length(qt_TexCoord0 - vec2(0.5));
                gl_FragColor = vec4(0.1, 0.1, 0.1, 0.1) * (smoothstep(0.5-border,0.505-border, dist) - smoothstep(0.5-0.005, 0.5, dist)) * qt_Opacity;
            }"
    }

    GlassItem {
        id: secondIndicator
        falloffRadius: 0.22
        radius: 0.25
        anchors.centerIn: parent
        color: mouse.changingProperty == 1 ? Theme.highlightColor : Theme.primaryColor

        property real value
        property bool animationEnabled: true

        transform: Translate {
            // The seconds circle ends at 132px from the center
            x: (width - 3*_minuteWidth)/2 * _xTranslation(secondIndicator.value, 60)
            y: -(height - 3*_minuteWidth)/2 * _yTranslation(secondIndicator.value, 60)
        }

        Behavior on value {
            id: secondsAnimation
            SmoothedAnimation { velocity: 80 }
            enabled: secondIndicator.animationEnabled && (!mouse.isMoving || mouse.isLagging)
        }
    }

    GlassItem {
        id: minuteIndicator
        falloffRadius: 0.22
        radius: 0.25
        anchors.centerIn: parent
        color: mouse.changingProperty == 2 ? Theme.highlightColor : Theme.primaryColor

        property real value
        property bool animationEnabled: true

        transform: Translate {
            // The minutes band is 72px wide, ending at 204px from the center
            x: (width - _minuteWidth)/2 * _xTranslation(minuteIndicator.value, 60)
            y: -(height - _minuteWidth)/2 * _yTranslation(minuteIndicator.value, 60)
        }

        Behavior on value {
            id: minutesAnimation
            SmoothedAnimation { velocity: 80 }
            enabled: minuteIndicator.animationEnabled && (!mouse.isMoving || mouse.isLagging)
        }
    }

    MouseArea {
        id: mouse

        property int changingProperty
        property bool isMoving
        property bool isLagging

        anchors.fill: parent
        preventStealing: true

        function radiusForCoord(x, y) {
            // Return the distance from the mouse position to the center
            return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2))
        }

        function angleForCoord(x, y) {
            // Return the angular position in degrees, rising anticlockwise from the positive X-axis
            var result = Math.atan(y / x) / (Math.PI * 2) * 360

            // Adjust for various quadrants
            if (x < 0)  {
                result += 180
            } else if (y < 0) {
                result += 360
            }
            return result
        }

        function remapAngle(value, bound) {
            // Return the angle in degrees mapped to the adjusted range 0 - (bound-1) and
            // translated to the clockwise from positive Y-axis orientation
            return Math.round(bound - (((value - 90) / 360) * bound)) % bound
        }

        function remapMouse(mouseX, mouseY) {
            // Return the mouse coordinates in cartesian coords relative to the circle center
            return { x: mouseX - (width / 2), y: 0 - (mouseY - (height / 2)) }
        }

        function propertyForRadius(radius) {
            // Return the property associated with clicking at radius distance from the center
            if (radius < 132) {
                return 1 // Seconds
            } else if (radius < 204) {
                return 2 // Minutes
            }
            return 0
        }

        function updateForAngle(angle) {
            // Update the selected property for the specified angular position
            if (changingProperty == 1) { //Seconds
                // Map angular position to 0-59
                var s = remapAngle(angle, 60)

                // Round single touch to the nearest 5 min mark
                if (!isMoving) s = (Math.round(s/5) * 5) % 60

                var delta = (s - secondIndicator.value) % 60

                // It is not possible to make jumps of more than 30 seconds - reverse the direction
                if (delta > 30) {
                    delta -= 60
                } else if (delta < -30) {
                    delta += 60
                }
                if (isMoving && isLagging) {
                    if (Math.abs(delta) < 2) {
                        isLagging = false
                    }
                }

                secondIndicator.value += delta

                timePicker.second = s
            } else { // Minutes
                // Map angular position to 0-59
                var m = remapAngle(angle, 60)

                // Round single touch to the nearest 5 min mark
                if (!isMoving) m = (Math.round(m/5) * 5) % 60

                var delta = (m - minuteIndicator.value) % 60

                // It is not possible to make jumps of more than 30 minutes - reverse the direction
                if (delta > 30) {
                    delta -= 60
                } else if (delta < -30) {
                    delta += 60
                }
                if (isMoving && isLagging) {
                    if (Math.abs(delta) < 2) {
                        isLagging = false
                    }
                }

                minuteIndicator.value += delta

                timePicker.minute = m
            }
        }

        onPressed: {
            var coords = remapMouse(mouseX, mouseY)
            var radius = radiusForCoord(coords.x, coords.y)

            changingProperty = propertyForRadius(radius)
            if (changingProperty != 0) {
                preventStealing = true
                var angle = angleForCoord(coords.x, coords.y)

                isLagging = true
                updateForAngle(angle)
            } else {
                // Outside the minutes band - allow pass through to underlying component
                preventStealing = false
            }
        }
        onPositionChanged: {
            if (changingProperty > 0) {
                var coords = remapMouse(mouseX, mouseY)
                var angle = angleForCoord(coords.x, coords.y)

                isMoving = true
                updateForAngle(angle)
            }
        }
        onReleased: {
            changingProperty = 0
            isMoving = false
            isLagging = false
        }
    }
}
