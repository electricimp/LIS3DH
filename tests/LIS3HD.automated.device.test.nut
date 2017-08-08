// MIT License
//
// Copyright (c) 2015-17 Electric Imp
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

class MyTestCase extends ImpTestCase {

    static DATA_WAIT = 1;

    _i2c = null;
    _intPin = null;

    function setUp() {
        _i2c = hardware.i2c89;
        _i2c.configure(CLOCK_SPEED_400_KHZ);
        _intPin = hardware.pin1;
    }

    function getLIS() {
        local accel = LIS3DH(_i2c, 0x32);
        accel.reset();
        accel.setDataRate(100);
        return accel;
    }

    function testSetReadRegs() {
        local myVal = 0x7f; // random value to go into a register
        local accel = getLIS();
        accel._setReg(LIS3DH_CTRL_REG3, myVal);
        this.assertEqual(myVal, accel._getReg(LIS3DH_CTRL_REG3));
    }

    function testInterruptLatching() {
        local accel = getLIS();
        accel.configureInterruptLatching(true);
        accel.configureClickInterrupt(true);
        accel.configureInertialInterrupt(true);

        imp.sleep(DATA_WAIT); // hopefully something gets asserted in this time

        this.assertTrue(accel.getInterruptTable() != 0);
    }

    function testConstruction() {
        local accel = LIS3DH(_i2c, 0x32);
        this.assertTrue(accel._addr == 0x32);
    }

    // test that calling reset correctly resets registers (in particular, 
    // data ready interrupt and range)
    function testInit() {
        local accel = LIS3DH(_i2c, 0x32);
        accel.reset();
        accel.setDataRate(1);
        accel.setRange(4);
        accel.configureDataReadyInterrupt(true);
        local val = false;
        _intPin.configure(DIGITAL_IN, function() {
            val = _intPin.read();
        }.bindenv(this));
        return Promise(function(resolve, reject) {
            accel.reset();
            val = false; // if reset does not reset interrupt and range, then intPin
            // will be asserted and therefore val will become true bfeore
            // the wakeup callback
            imp.wakeup(DATA_WAIT, function() {
                if (val || (accel.getRange() != 2)) {
                    reject("did not reset data ready interrupt and/or range");
                } else {
                    resolve("rejected data ready interrupt and reset range via reset");
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    function testDeviceId() {
        local accel = LIS3DH(_i2c, 0x32);
        this.assertTrue(accel.getDeviceId() == 51);
    }

    function testSetDataRate() {
        local accel = LIS3DH(_i2c, 0x32);
        local r0 = accel.setDataRate(0);
        local r1 = accel.setDataRate(1);
        local r2 = accel.setDataRate(10);
        this.assertTrue((r0 == 0) && (r1 == 1) && (r2 == 10));
    }

    function testGetAccelSync() {
        local accel = getLIS();
        local res = accel.getAccel();
        this.assertTrue(("x" in res ? typeof res.x == "float" : false) &&
                        ("y" in res ? typeof res.y == "float" : false) && 
                        ("z" in res ? typeof res.z == "float" : false));
    }

    function testGetAccelAsync() {
        return Promise(function(resolve, reject) {
            local accel = getLIS();
            accel.getAccel(function(res) {
                if (("x" in res ? typeof res.x == "float" : false) &&
                    ("y" in res ? typeof res.y == "float" : false) && 
                    ("z" in res ? typeof res.z == "float" : false)) {
                    resolve("async resolved successfully");
                } else {
                    reject("async did not resolve succesfully");
                }
            }.bindenv(this));
        }.bindenv(this));
    }

    function testEnable() {
        return Promise(function(resolve, reject) {
            local accel = getLIS();
            accel.enable(false);
            imp.wakeup(DATA_WAIT, function() {
                local res = accel.getAccel();
                if (res.x || res.y || res.z) {
                    reject("failed to disable axes");
                } else {
                    accel.enable(true);
                    imp.wakeup(DATA_WAIT, function() {
                        res = accel.getAccel();
                        // technically it's possible to have all axes at 0 
                        // acceleration but it's unlikedly
                        if (!(res.x || res.y || res.z)) {
                            reject("failed to enable axes");
                        } else {
                            resolve("successfully disabled and enabled axes");
                        }
                    }.bindenv(this));
                }   
            }.bindenv(this));
        }.bindenv(this))
    }
}