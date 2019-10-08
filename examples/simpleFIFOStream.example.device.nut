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
// This example sets the FIFO buffer to Stream Mode and reads the data from the 
// buffer whenever the watermark is reached:

#require "LIS3DH.device.lib.nut:3.0.0"

function readBuffer() {
    if (intPin.read() == 0) return;

    // Read buffer
    local stats = accel.getFifoStats();
    for (local i = 0 ; i < stats.unread ; i++) {
        local data = accel.getAccel();
        server.log(format("Accel (x,y,z): [%f, %f, %f]", data.x, data.y, data.z));
    }

    // Check if we are now over-run
    stats = accel.getFifoStats();
    if (stats.overrun) {
        server.error("Accelerometer buffer over-run");

        // Set FIFO mode to bypass to clear the buffer and then return to stream mode
        accel.configureFifo(true, LIS3DH_FIFO_BYPASS_MODE);
        accel.configureFifo(true, LIS3DH_FIFO_STREAM_MODE);
    }
}

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);

// Configure interrupt pin
intPin <- hardware.pin1;
intPin.configure(DIGITAL_IN_PULLDOWN, readBuffer);

// Reset accel to defalult settings
accel.reset();
// Configure accelerometer
accel.setDataRate(100);

server.log("Log accel streaming data using FIFO interrupt...");
server.log("------------------------------------------------");

// Configure the FIFO buffer in Stream Mode 
accel.configureFifo(true, LIS3DH_FIFO_STREAM_MODE);
// Configure interrupt to trigger when there are 30 entries in the buffer
accel.configureFifoInterrupts(true, false, 30);

// This example will log a ton, so stop after a few seconds
imp.wakeup(5, function() {
    accel.configureFifo(false);
    accel.configureFifoInterrupts(false);
    
    server.log("Stop logging accel streaming data.");
    server.log("------------------------------------------------");
}) 
