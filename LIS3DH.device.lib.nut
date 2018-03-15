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


// Registers
const LIS3DH_TEMP_CFG_REG  = 0x1F;
const LIS3DH_CTRL_REG1     = 0x20;
const LIS3DH_CTRL_REG2     = 0x21;
const LIS3DH_CTRL_REG3     = 0x22;
const LIS3DH_CTRL_REG4     = 0x23;
const LIS3DH_CTRL_REG5     = 0x24;
const LIS3DH_CTRL_REG6     = 0x25;
const LIS3DH_OUT_X_L_INCR  = 0xA8;
const LIS3DH_OUT_X_L       = 0x28;
const LIS3DH_OUT_X_H       = 0x29;
const LIS3DH_OUT_Y_L       = 0x2A;
const LIS3DH_OUT_Y_H       = 0x2B;
const LIS3DH_OUT_Z_L       = 0x2C;
const LIS3DH_OUT_Z_H       = 0x2D;
const LIS3DH_FIFO_CTRL_REG = 0x2E;
const LIS3DH_FIFO_SRC_REG  = 0x2F;
const LIS3DH_INT1_CFG      = 0x30;
const LIS3DH_INT1_SRC      = 0x31;
const LIS3DH_INT1_THS      = 0x32;
const LIS3DH_INT1_DURATION = 0x33;
const LIS3DH_CLICK_CFG     = 0x38;
const LIS3DH_CLICK_SRC     = 0x39;
const LIS3DH_CLICK_THS     = 0x3A;
const LIS3DH_TIME_LIMIT    = 0x3B;
const LIS3DH_TIME_LATENCY  = 0x3C;
const LIS3DH_TIME_WINDOW   = 0x3D;
const LIS3DH_WHO_AM_I      = 0x0F;


// Bitfield values
const LIS3DH_X_LOW         = 0x01;
const LIS3DH_X_HIGH        = 0x02;
const LIS3DH_Y_LOW         = 0x04;
const LIS3DH_Y_HIGH        = 0x08;
const LIS3DH_Z_LOW         = 0x10;
const LIS3DH_Z_HIGH        = 0x20;
const LIS3DH_SIX_D         = 0x40;
const LIS3DH_AOI           = 0x80;

// High Pass Filter values
const LIS3DH_HPF_DISABLED               = 0x00;
const LIS3DH_HPF_AOI_INT1               = 0x01;
const LIS3DH_HPF_AOI_INT2               = 0x02;
const LIS3DH_HPF_CLICK                  = 0x04;
const LIS3DH_HPF_FDS                    = 0x08;

const LIS3DH_HPF_CUTOFF1                = 0x00;
const LIS3DH_HPF_CUTOFF2                = 0x10;
const LIS3DH_HPF_CUTOFF3                = 0x20;
const LIS3DH_HPF_CUTOFF4                = 0x30;

const LIS3DH_HPF_DEFAULT_MODE           = 0x00;
const LIS3DH_HPF_REFERENCE_SIGNAL       = 0x40;
const LIS3DH_HPF_NORMAL_MODE            = 0x80;
const LIS3DH_HPF_AUTORESET_ON_INTERRUPT = 0xC0;

const LIS3DH_FIFO_BYPASS_MODE           = 0x00;
const LIS3DH_FIFO_FIFO_MODE             = 0x40;
const LIS3DH_FIFO_STREAM_MODE           = 0x80;
const LIS3DH_FIFO_STREAM_TO_FIFO_MODE   = 0xC0;

// Click Detection values
const LIS3DH_SINGLE_CLICK  = 0x15;
const LIS3DH_DOUBLE_CLICK  = 0x2A;

const LIS3DH_MODE_NORMAL = 0x00;
const LIS3DH_MODE_LOW_POWER = 0x01;
const LIS3DH_MODE_HIGH_RESOLUTION = 0x02;

const LIS3DH_ADC1 = 0x01;
const LIS3DH_ADC2 = 0x02;
const LIS3DH_ADC3 = 0x03;

class LIS3DH {
    static VERSION = "2.0.0";

    // I2C information
    _i2c = null;
    _addr = null;
    _mode = LIS3DH_MODE_NORMAL;

    // The full-scale range (+/- _range G)
    _range = null;

    constructor(i2c, addr = 0x30) {
        _i2c = i2c;
        _addr = addr;

        // Read the range + set _range property
        getRange();
    }

    // Set default values for registers, read the current range and set _range
    // (resets to state when first powered on)
    function reset() {
        // Set default values for registers
        _setReg(LIS3DH_CTRL_REG1, 0x07);
        _setReg(LIS3DH_CTRL_REG2, 0x00);
        _setReg(LIS3DH_CTRL_REG3, 0x00);
        _setReg(LIS3DH_CTRL_REG4, 0x00);
        _setReg(LIS3DH_CTRL_REG5, 0x00);
        _setReg(LIS3DH_CTRL_REG6, 0x00);
        _setReg(LIS3DH_INT1_CFG, 0x00);
        _setReg(LIS3DH_INT1_THS, 0x00);
        _setReg(LIS3DH_INT1_DURATION, 0x00);
        _setReg(LIS3DH_CLICK_CFG, 0x00);
        _setReg(LIS3DH_CLICK_SRC, 0x00);
        _setReg(LIS3DH_CLICK_THS, 0x00);
        _setReg(LIS3DH_TIME_LIMIT, 0x00);
        _setReg(LIS3DH_TIME_LATENCY, 0x00);
        _setReg(LIS3DH_TIME_WINDOW, 0x00);
        _setReg(LIS3DH_FIFO_CTRL_REG, 0x00);

        // Read the range + set _range property
        getRange();
    }

    // Enable the ADC. The ADC sampling frequency is the same as that of the ODR
    // in LISxDH_CTRL_REG1. The input range is 0.8-1.6v and the
    // data output is expressed in 2's complement left-aligned. The resolution is
    // 8-bit in low-power mode 10 bits otherwise
    function enableADC(state) {
        _setRegBit(LIS3DH_TEMP_CFG_REG, 7, state);
        _setRegBit(LIS3DH_CTRL_REG4, 7, state);
    }

    // This method returns the current value of the ADC line. You must pass one of
    // the lines (1, 2, or 3) or you will get an invalid return value. You must also
    // have enabled the ADC by calling enableADC(true)
    function readADC(ADC_line) {
        local reg = (ADC_line * 2) + 6;
        local read = _getMultiReg(reg, 2);

        // Shift and sign extend
        local val = (((read[0] >> 6) | (read[1] << 2)) << 22) >> 22;

        val = val / 512.0; // In low-power mode, there will be lower resolution

        // Affine transformation to map to appropriate voltage
        return (val * 0.4) + 1.2;
    }

    // Read data from the Accelerometer
    // Returns a table {x: <data>, y: <data>, z: <data>}
    function getAccel(cb = null) {
        local result = {};

        try {
            // Read entire block with auto-increment
            local reading = _getMultiReg(LIS3DH_OUT_X_L_INCR, 6);
            // Read and sign extend
            result.x <- ((reading[0] | (reading[1] << 8)) << 16) >> 16;
            result.y <- ((reading[2] | (reading[3] << 8)) << 16) >> 16;
            result.z <- ((reading[4] | (reading[5] << 8)) << 16) >> 16;

            // multiply by full-scale range to return in G
            result.x = (result.x / 32000.0) * _range;
            result.y = (result.y / 32000.0) * _range;
            result.z = (result.z / 32000.0) * _range;
        } catch (e) {
            result.error <- e;
        }

        // Return table if no callback was passed
        if (cb == null) { return result; }

        // Invoke the callback if one was passed
        imp.wakeup(0, function() { cb(result); });
    }

    // Set Accelerometer Data Rate in Hz
    function setDataRate(rate) {
        local val = _getReg(LIS3DH_CTRL_REG1) & 0x0F;
        local normalMode = (val < 8);
        if (rate == 0) {
            // 0b0000 -> power-down mode
            // we've already ANDed-out the top 4 bits; just write back
            rate = 0;
        } else if (rate <= 1) {
            val = val | 0x10;
            rate = 1;
        } else if (rate <= 10) {
            val = val | 0x20;
            rate = 10;
        } else if (rate <= 25) {
            val = val | 0x30;
            rate = 25;
        } else if (rate <= 50) {
            val = val | 0x40;
            rate = 50;
        } else if (rate <= 100) {
            val = val | 0x50;
            rate = 100;
        } else if (rate <= 200) {
            val = val | 0x60;
            rate = 200;
        } else if (rate <= 400) {
            val = val | 0x70;
            rate = 400;
        } else if (normalMode) {
            val = val | 0x90;
            rate = 1250;
        } else if (rate <= 1600) {
            val = val | 0x80;
            rate = 1600;
        } else {
            val = val | 0x90;
            rate = 5000;
        }
        _setReg(LIS3DH_CTRL_REG1, val);
        return rate;
    }

    // set the full-scale range of the accelerometer (default +/- 2G)
    function setRange(rangeA) {
        local val = _getReg(LIS3DH_CTRL_REG4) & 0xCF;
        local rangeBits = 0;
        if (rangeA <= 2) {
            rangeBits = 0x00;
            _range = 2;
        } else if (rangeA <= 4) {
            rangeBits = 0x01;
            _range = 4;
        } else if (rangeA <= 8) {
            rangeBits = 0x02;
            _range = 8;
        } else {
            rangeBits = 0x03;
            _range = 16;
        }
        _setReg(LIS3DH_CTRL_REG4, val | (rangeBits << 4));
        return _range;
    }

    // get the currently-set full-scale range of the accelerometer
    function getRange() {
        local range_bits = (_getReg(LIS3DH_CTRL_REG4) & 0x30) >> 4;
        if (range_bits == 0x00) {
            _range = 2;
        } else if (range_bits == 0x01) {
            _range = 4;
        } else if (range_bits == 0x02) {
            _range = 8;
        } else {
            _range = 16;
        }
        return _range;
    }

    // Set the mode of the accelerometer by passing a constant (LIS3DH_MODE_NORMAL,
    // LIS3DH_MODE_LOW_POWER, LIS3DH_MODE_HIGH_RESOLUTION)
    function setMode(mode) {
        _setRegBit(LIS3DH_CTRL_REG1, 3, mode & 0x01);
        _setRegBit(LIS3DH_CTRL_REG4, 3, mode & 0x02);
        _mode = mode;
    }

    // Returns the deviceID (should be 51)
    function getDeviceId() {
        return _getReg(LIS3DH_WHO_AM_I);
    }

    function configureHighPassFilter(filters, cutoff = LIS3DH_HPF_CUTOFF1, mode = LIS3DH_HPF_DEFAULT_MODE) {
        // clear and set filters
        filters = LIS3DH_HPF_DISABLED | filters;

        // set register
        _setReg(LIS3DH_CTRL_REG2, filters | cutoff | mode);
    }

    //-------------------- INTERRUPTS --------------------//

    // Enable/disable and configure FIFO buffer watermark interrupts
    function configureFifoInterrupt(enable, fifomode = 0x80, watermark = 28) {

        // Enable/disable the FIFO buffer
        _setRegBit(LIS3DH_CTRL_REG5, 6, enable ? 1 : 0);

        if (enable) {
            // Stream-to-FIFO mode, watermark of [28].
            _setReg(LIS3DH_FIFO_CTRL_REG, (fifomode & 0xc0) | (watermark & 0x1F));
        } else {
            _setReg(LIS3DH_FIFO_CTRL_REG, 0x00);
        }

        // Enable/disable watermark interrupt
        _setRegBit(LIS3DH_CTRL_REG3, 2, enable ? 1 : 0);

    }

    // Enable/disable and configure inertial interrupts
    function configureInertialInterrupt(enable, threshold = 2.0, duration = 5,
    options = LIS3DH_X_HIGH | LIS3DH_Y_HIGH | LIS3DH_Z_HIGH) {

        // Set the enable flag
        _setRegBit(LIS3DH_CTRL_REG3, 6, enable ? 1 : 0);

        // If we're disabling the interrupt, don't set anything else
        if (!enable) return;

        // Clamp the threshold
        if (threshold < 0) { threshold = threshold * -1.0; }    // Make sure we have a positive value
        if (threshold > _range) { threshold = _range; }          // Make sure it doesn't exceed the _range

        // Set the threshold
        threshold = (((threshold * 1.0) / (_range)) * 127).tointeger();
        _setReg(LIS3DH_INT1_THS, (threshold & 0x7f));

        // Set the duration
        _setReg(LIS3DH_INT1_DURATION, duration & 0x7f);

        // Set the options flags
        _setReg(LIS3DH_INT1_CFG, options);
    }

    // Enable/disable and configure an inertial interrupt to detect free fall
    function configureFreeFallInterrupt(enable, threshold = 0.5, duration = 5) {
        configureInertialInterrupt(enable, threshold, duration, LIS3DH_AOI | LIS3DH_X_LOW | LIS3DH_Y_LOW | LIS3DH_Z_LOW);
    }

    // Enable/disable and configure click interrupts
    function configureClickInterrupt(enable, clickType = LIS3DH_SINGLE_CLICK, threshold = 1.1, timeLimit = 5, latency = 10, window = 50) {

        // Set the enable / disable flag
        _setRegBit(LIS3DH_CTRL_REG3, 7, enable ? 1 : 0);

        // If they disabled the click interrupt, set LIS3DH_CLICK_CFG register and return
        if (!enable) {
            _setReg(LIS3DH_CLICK_CFG, 0x00);
            return;
        }

        // Set the LIS3DH_CLICK_CFG register
        _setReg(LIS3DH_CLICK_CFG, clickType);

        // Set the LIS3DH_CLICK_THS register
        if (threshold < 0) { threshold = threshold * -1.0; }    // Make sure we have a positive value
        if (threshold > _range) { threshold = _range; }          // Make sure it doesn't exceed the _range

        threshold = (((threshold * 1.0) / (_range)) * 127).tointeger();
        _setReg(LIS3DH_CLICK_THS, threshold);

        // Set the LIS3DH_TIME_LIMIT register (max time for a click)
        _setReg(LIS3DH_TIME_LIMIT, timeLimit);
        // Set the LIS3DH_TIME_LATENCY register (min time between clicks for double click)
        _setReg(LIS3DH_TIME_LATENCY, latency);
        // Set the LIS3DH_TIME_WINDOW register (max time for double click)
        _setReg(LIS3DH_TIME_WINDOW, window);
    }

    // Enable/Disable Data Ready Interrupt 1 on Interrupt Pin
    function configureDataReadyInterrupt(enable) {
        _setRegBit(LIS3DH_CTRL_REG3, 4, enable ? 1 : 0);
    }

    // Enables/disables interrupt latching
    function configureInterruptLatching(enable) {
        _setRegBit(LIS3DH_CTRL_REG5, 3, enable ? 1 : 0);
        _setRegBit(LIS3DH_CLICK_THS, 7, enable ? 1 : 0);
    }

    // Returns interrupt registers as a table, and clears the LIS3DH_INT1_SRC register
    function getInterruptTable() {
        local int1 = _getReg(LIS3DH_INT1_SRC);
        local click = _getReg(LIS3DH_CLICK_SRC);

        return {
            "int1":         (int1 & 0x40) != 0,
            "xLow":         (int1 & 0x01) != 0,
            "xHigh":        (int1 & 0x02) != 0,
            "yLow":         (int1 & 0x04) != 0,
            "yHigh":        (int1 & 0x08) != 0,
            "zLow":         (int1 & 0x10) != 0,
            "zHigh":        (int1 & 0x20) != 0,
            "click":        (click & 0x40) != 0,
            "singleClick":  (click & 0x10) != 0,
            "doubleClick":  (click & 0x20) != 0
        }
    }

    function getFifoStats() {
        local stats = _getReg(LIS3DH_FIFO_SRC_REG);
        return {
            "watermark": (stats & 0x80) != 0,
            "overrun": (stats & 0x40) != 0,
            "empty": (stats & 0x20) != 0,
            "unread": (stats & 0x1F) + ((stats & 0x40) ? 1 : 0)
        }
    }

    // Set the state of the accelerometer axes
    function enable(state = true) {
        // LIS3DH_CTRL_REG1 enables/disables accelerometer axes
        // bit 0 = X axis
        // bit 1 = Y axis
        // bit 2 = Z axis
        local val = _getReg(LIS3DH_CTRL_REG1);
        if (state) { val = val | 0x07; }
        else { val = val & 0xF8; }
        _setReg(LIS3DH_CTRL_REG1, val);
    }

    //-------------------- PRIVATE METHODS --------------------//

    function _getReg(reg) {
        local result = _i2c.read(_addr, reg.tochar(), 1);
        if (result == null) {
            throw "I2C read error: " + _i2c.readerror();
        }
        return result[0];
    }

    function _getMultiReg(reg, numBits) {
        // Read entire block with auto-increment
        local result = _i2c.read(_addr, reg.tochar(), numBits);
        if (result == null) {
            throw "I2C read error: " + _i2c.readerror();
        }
        return result;
    }

    function _setReg(reg, val) {
        local result = _i2c.write(_addr, format("%c%c", reg, (val & 0xff)));
        if (result) {
            throw "I2C write error: " + result;
        }
        return result;
    }

    function _setRegBit(reg, bit, state) {
        local val = _getReg(reg);
        if (state == 0) {
            val = val & ~(0x01 << bit);
        } else {
            val = val | (0x01 << bit);
        }
        return _setReg(reg, val);
    }

    function _dumpRegs() {
        server.log(format("LIS3DH_CTRL_REG1 0x%02X", _getReg(LIS3DH_CTRL_REG1)));
        server.log(format("LIS3DH_CTRL_REG2 0x%02X", _getReg(LIS3DH_CTRL_REG2)));
        server.log(format("LIS3DH_CTRL_REG3 0x%02X", _getReg(LIS3DH_CTRL_REG3)));
        server.log(format("LIS3DH_CTRL_REG4 0x%02X", _getReg(LIS3DH_CTRL_REG4)));
        server.log(format("LIS3DH_CTRL_REG5 0x%02X", _getReg(LIS3DH_CTRL_REG5)));
        server.log(format("LIS3DH_CTRL_REG6 0x%02X", _getReg(LIS3DH_CTRL_REG6)));
        server.log(format("LIS3DH_INT1_DURATION 0x%02X", _getReg(LIS3DH_INT1_DURATION)));
        server.log(format("LIS3DH_INT1_CFG 0x%02X", _getReg(LIS3DH_INT1_CFG)));
        server.log(format("LIS3DH_INT1_SRC 0x%02X", _getReg(LIS3DH_INT1_SRC)));
        server.log(format("LIS3DH_INT1_THS 0x%02X", _getReg(LIS3DH_INT1_THS)));
        server.log(format("LIS3DH_FIFO_CTRL_REG 0x%02X", _getReg(LIS3DH_FIFO_CTRL_REG)));
        server.log(format("LIS3DH_FIFO_SRC_REG 0x%02X", _getReg(LIS3DH_FIFO_SRC_REG)));
    }
}
