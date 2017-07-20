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

@include "github:electricimp/LIS3DH/LIS3DH.device.lib.nut@v2.0.0"

class MyTestCase extends ImpTestCase {
	
	function getLIS() {
		local i2c = hardware.i2cJK;
		i2c.configure(CLOCK_SPEED_400_KHZ);
		local accel <- LIS3DH(i2c, 0x30);
		accel.init();
		accel.setDataRate(100);
		return accel;
	}

	function testSetReadRegs() {
		local myVal = 0x7f; // random value to go into a register
		local accel = getLIS();
		accel._setReg(LIS3DH_CTRL_REG3, myVal);
		this.assertEqual(myVal, accel._getReg(LIS3DH_CTRL_REG3));
	}

	function testAccel() {
		local accel = getLIS();
		local reading = accel.getAccel();
		this.assertBetween(reading.z, -1.1, -0.9); // for this test, the accelerometer should be sitting still facing up
	}

	function testADC() {
		local accel = getLIS();
		accel.enableADC(true);
		this.assertBetween(accel.readADC(LIS3DH_ADC1), 1.15, 1.25); // for this test, line 1 of the accelerometer ADC should be fed 1.2V
	}

	function testInterruptLatching() {
		local accel = getLIS();
		accel.configureInterruptLatching(true);
		accel.configureClickInterrupt(true);
		accel.configureInertialInterrupt(true);

		imp.sleep(1); // hopefully something gets asserted in this time

		this.assertTrue(accel.getInterruptTable() != 0);
	}
}