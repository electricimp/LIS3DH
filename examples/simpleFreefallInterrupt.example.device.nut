// MIT License
//
// Copyright (c) 2015-19 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// ----------------------------------------------------------------------------
// In the following example we setup an interrupt for free-fall detection:

function sensorSetup() {
    // Configure accelerometer
    accel.setDataRate(100);
    accel.configureInterruptLatching(true);

    // Set up a free fall interrupt
    accel.configureFreeFallInterrupt(true);
}

// Put imp to Sleep
function sleep(timer) {
    server.log("Going to sleep for " + timer + " sec");
    if (server.isconnected()) {
        imp.onidle(function() {
            server.sleepfor(timer);
        });
    } else {
        imp.deepsleepfor(timer);
    }
}

// Take reading
function takeReading() {
    accel.getAccel(function(result) {
        if ("err" in result) {
            // Check for error
            server.error(result.err);
        } else {
            // Add timestamp to result table
            result.ts <- time();

            // log reading
            foreach(k, v in result) {
                server.log(k + ": " + v);
            }
        }
    });
}

function interruptHandler() {
    if (int.read() == 0) return;

    // Get + clear the interrupt + clear
    local data = accel.getInterruptTable();

    // Check what kind of interrupt it was
    if (data.int1) server.log("Free Fall");

    sleep(30);
}

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);

wake <- hardware.pin1;
wake.configure(DIGITAL_IN_WAKEUP);

// Handle WakeUp
switch(hardware.wakereason()) {
    case WAKEREASON_TIMER:
        server.log("WOKE UP B/C TIMER EXPIRED");
        takeReading();
        imp.wakeup(2, function() {
            sleep(30);
        });
        break;
    case WAKEREASON_PIN:
        server.log("WOKE UP B/C PIN HIGH");
        interruptHandler();
        break;
    default:
        server.log("WOKE UP B/C RESTARTED DEVICE, LOADED NEW CODE, ETC");
        sensorSetup();
        takeReading();
        imp.wakeup(2, function() {
            sleep(30);
        });
}