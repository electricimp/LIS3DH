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
// Simple motion and impact detection example: 

#require "LIS3DH.device.lib.nut:3.0.0"

// Configure i2c and accelerometer
// ----------------------------------------------------------------------------
i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

ACCEL_INT <- hardware.pin1;
const ACCEL_DATA_RATE = 100;

// Use a non-default I2C address (SA0 pulled high)
accel <- LIS3DH(i2c, 0x32);


// Supporting application functions
// ----------------------------------------------------------------------------
function getMagnitude(r) {
    return math.sqrt(r.x*r.x + r.y*r.y + r.z*r.z); 
}

function onInterrupt() {
    if (ACCEL_INT.read() == 0) return;
    
    server.log("----------------------");
    server.log("Interrupt triggered...");
    
    // Check interrupt table to confirm motion interrupt triggered
    local res = accel.getInterruptTable();
    if (res.int1) {
        server.log("Motion detected. Checking Fifo buffer: ");
    }

    // Get data from FIFO buffer, determine the maximum magnitude
    local stats = accel.getFifoStats();
    local max = null;
    local raw = null;
    for (local i = 0 ; i < stats.unread ; i++) {
        local data = accel.getAccel();
        local mag = getMagnitude(data);
        if (mag > max) {
            max = mag;
            raw = data;
        }
    }
    if (max != null) {
        server.log(format("Max mag: %f, Accel (x,y,z): [%f, %f, %f]", max, raw.x, raw.y, raw.z));
    }
    server.log("----------------------");
    // Reset FIFO Buffer
    enableImpactCapture();
}

function enableAccel() {
    accel.reset();
    accel.setDataRate(ACCEL_DATA_RATE);
    accel.setMode(LIS3DH_MODE_LOW_POWER);
    accel.enable(true);
}

function enableMotionInterrupt() {
    local threshold = 0.05;
    local duration  = 50;
    
    accel.configureHighPassFilter(LIS3DH_HPF_AOI_INT1, LIS3DH_HPF_CUTOFF1, LIS3DH_HPF_NORMAL_MODE);
    accel.getInterruptTable();
    accel.configureInertialInterrupt(true, threshold, duration);
    accel.configureInterruptLatching(false);
    
    ACCEL_INT.configure(DIGITAL_IN_WAKEUP, onInterrupt);
}

function enableImpactCapture() {
    accel.configureFifo(true, LIS3DH_FIFO_BYPASS_MODE);
    accel.configureFifo(true, LIS3DH_FIFO_STREAM_TO_FIFO_MODE);
}

// RUNTIME
// -------------------------------------------------
imp.enableblinkup(true);
server.log("Device Running...");
server.log(imp.getsoftwareversion());

// Start monitor
enableAccel();
enableImpactCapture();
enableMotionInterrupt();
