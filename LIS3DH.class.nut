class LIS3DH {
    static version = [1,0,0];

    // Registers
    static TEMP_CFG_REG  = 0x1F;
    static CTRL_REG1     = 0x20;
    static CTRL_REG2     = 0x21;
    static CTRL_REG3     = 0x22;
    static CTRL_REG4     = 0x23;
    static CTRL_REG5     = 0x24;
    static CTRL_REG6     = 0x25;
    static OUT_X_L       = 0x28;
    static OUT_X_H       = 0x29;
    static OUT_Y_L       = 0x2A;
    static OUT_Y_H       = 0x2B;
    static OUT_Z_L       = 0x2C;
    static OUT_Z_H       = 0x2D;
    static INT1_CFG      = 0x30;
    static INT1_SRC      = 0x31;
    static INT1_THS      = 0x32;
    static INT1_DURATION = 0x33;
    static CLICK_CFG     = 0x38;
    static CLICK_SRC     = 0x39;
    static CLICK_THS     = 0x3A;
    static TIME_LIMIT    = 0x3B;
    static TIME_LATENCY  = 0x3C;
    static TIME_WINDOW   = 0x3D;
    static WHO_AM_I      = 0x0F;

    // bitfield values
    static X_LOW         = 0x01;
    static X_HIGH        = 0x02;
    static Y_LOW         = 0x04;
    static Y_HIGH        = 0x08;
    static Z_LOW         = 0x10;
    static Z_HIGH        = 0x20;
    static SIX_D         = 0x40;
    static AOI           = 0x80;

    // Click Detection values
    static SINGLE_CLICK  = 0x15;
    static DOUBLE_CLICK  = 0x2A;


    // I2C information
    _i2c = null;
    _addr = null;

    // The full-scale range (+/- _range G)
    _range = null;

    constructor(i2c, addr = 0x30) {
        _i2c = i2c;
        _addr = addr;

        init();
    }


    // set default values for registers, read the current range and set _range
    // (resets to state when first powered on)
    function init() {
        // Set default values for registers
        _setReg(CTRL_REG1, 0x07);
        _setReg(CTRL_REG2, 0x00);
        _setReg(CTRL_REG3, 0x00);
        _setReg(CTRL_REG4, 0x00);
        _setReg(CTRL_REG5, 0x00);
        _setReg(CTRL_REG6, 0x00);
        _setReg(INT1_CFG, 0x00);
        _setReg(INT1_THS, 0x00);
        _setReg(INT1_DURATION, 0x00);
        _setReg(CLICK_CFG, 0x00);
        _setReg(CLICK_SRC, 0x00);
        _setReg(CLICK_THS, 0x00);
        _setReg(TIME_LIMIT, 0x00);
        _setReg(TIME_LATENCY, 0x00);
        _setReg(TIME_WINDOW, 0x00);

        // Read the range + set _range property
        getRange();
    }

    // Read data from the Accelerometer
    // Returns a table {x: <data>, y: <data>, z: <data>}
    function getAccel(cb = null) {
        local x_raw = (_getReg(OUT_X_H) << 8) + _getReg(OUT_X_L);
        local y_raw = (_getReg(OUT_Y_H) << 8) + _getReg(OUT_Y_L);
        local z_raw = (_getReg(OUT_Z_H) << 8) + _getReg(OUT_Z_L);

        local result = {};
        if (x_raw & 0x8000) {
            result.x <- (-1.0) * _twosComp(x_raw, 0xffff);
        } else {
            result.x <- x_raw;
        }

        if (y_raw & 0x8000) {
            result.y <- (-1.0) * _twosComp(y_raw, 0xffff);
        } else {
            result.y <- y_raw;
        }

        if (z_raw & 0x8000) {
            result.z <- (-1.0) * _twosComp(z_raw, 0xffff);
        } else {
            result.z <- z_raw;
        }

        // multiply by full-scale range to return in G
        result.x = (result.x / 32000.0) * _range;
        result.y = (result.y / 32000.0) * _range;
        result.z = (result.z / 32000.0) * _range;

        // Return table if no callback was passed
        if (cb == null) { return result; }

        // Invoke the callback if one was passed
        imp.wakeup(0, function() { cb(result); });
    }

    // Set Accelerometer Data Rate in Hz
    function setDataRate(rate) {
        local val = _getReg(CTRL_REG1) & 0x0F;
        if (rate == 0) {
            // 0b0000 -> power-down mode
            // we've already ANDed-out the top 4 bits; just write back
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
        } else if (rate <= 1600) {
            val = val | 0x80;
            rate = 1600;
        } else if (rate <= 5000) {
            val = val | 0x90;
            rate = 5000;
        }
        _setReg(CTRL_REG1, val);
        return rate;
    }

    // set the full-scale range of the accelerometer (default +/- 2G)
    function setRange(range_a) {
        local val = _getReg(CTRL_REG2) & 0xC7;
        local range_bits = 0;
        if (range_a <= 2) {
            range_bits = 0x00;
            _range = 2;
        } else if (range_a <= 4) {
            range_bits = 0x01;
            _range = 4;
        } else if (range_a <= 6) {
            range_bits = 0x02;
            _range = 6;
        } else if (range_a <= 8) {
            range_bits = 0x03;
            _range = 8;
        } else {
            range_bits = 0x04;
            _range = 16;
        }
        _setReg(CTRL_REG2, val | (range_bits << 3));
        return _range;
    }

    // get the currently-set full-scale range of the accelerometer
    function getRange() {
        local range_bits = (_getReg(CTRL_REG2) & 0x38) >> 3;
        if (range_bits == 0x00) {
            _range = 2;
        } else if (range_bits = 0x01) {
            _range = 4;
        } else if (range_bits = 0x02) {
            _range = 6;
        } else if (range_bits = 0x03) {
            _range = 8;
        } else {
            _range = 16;
        }
        return _range;
    }

    // Enable/disable the accelerometer (all 3-axes)
    function enable(state = true) {
        // CTRL_REG1 enables/disables accelerometer axes
        // bit 0 = X axis
        // bit 1 = Y axis
        // bit 2 = Z axis
        local val = _getReg(CTRL_REG1);
        if (state) { val = val | 0x07; }
        else { val = val & 0xF8; }
        _setReg(CTRL_REG1, val);
    }

    // Enables /disables low power mude
    function setLowPower(state) {
        _setRegBit(CTRL_REG1, 3, state ? 1 : 0);
    }

    // Returns the deviceID (should be 51)
    function getDeviceId() {
        return _getReg(WHO_AM_I);
    }

    //-------------------- INTERRUPTS --------------------//

    // Enable/disable and configure inertial interrupts
    function configureInertialInterrupt(state, threshold = 2.0, duration = 5, options = null) {
        // Set default value for options (using statics, so can't set in ftcn declaration)
        if (options == null) { options = X_HIGH | Y_HIGH | Z_HIGH; }

        // Set the enable flag
        _setRegBit(CTRL_REG3, 6, state ? 1 : 0);

        // If we're disabling the interrupt, don't set anything else
        if (!state) return;

        // Clamp the threshold
        if (threshold < 0) { threshold = threshold * -1.0; }    // Make sure we have a positive value
        if (threshold > _range) { threshold = range; }          // Make sure it doesn't exceed the _range

        // Set the threshold
        threshold = (((threshold * 1.0) / (_range * 1.0)) * 127).tointeger();
        _setReg(INT1_THS, (threshold & 0x7f));

        // Set the duration
        _setReg(INT1_DURATION, duration & 0x7f);

        // Set the options flags
        _setReg(INT1_CFG, options);
    }

    // Enable/disable and configure an inertial interrupt to detect free fall
    function configureFreeFallInterrupt(state, threshold = 0.5, duration = 5) {
        configureInertialInterrupt(state, threshold, duration, AOI | X_LOW | Y_LOW | Z_LOW);
    }

    // Enable/disable and configure click interrupts
    function configureClickInterrupt(state, clickType = null, threshold = 1.1, timeLimit = 5, latency = 10, window = 50) {
        // Set default value for clickType (since we're using statics we can't set in function definition)
        if (clickType == null) clickType = SINGLE_CLICK;

        // Set the enable / disable flag
        _setRegBit(CTRL_REG3, 7, state ? 1 : 0);

        // If they disabled the click interrupt, set click_cfg register and return
        if (!state) {
            _setReg(CLICK_CFG, 0x00);
            return;
        }

        // Set the CLICK_CFG register
        _setReg(CLICK_CFG, clickType);

        // Set the CLICK_THS register
        if (threshold < 0) { threshold = threshold * -1.0; }    // Make sure we have a positive value
        if (threshold > _range) { threshold = range; }          // Make sure it doesn't exceed the _range

        threshold = (((threshold * 1.0) / (_range * 1.0)) * 127).tointeger();
        _setReg(CLICK_THS, threshold);

        // Set the TIME_LIMIT register (max time for a click)
        _setReg(TIME_LIMIT, timeLimit);
        // Set the TIME_LATENCY register (min time between clicks for double click)
        _setReg(TIME_LATENCY, latency);
        // Set the TIME_WINDOW register (max time for double click)
        _setReg(TIME_WINDOW, window);
    }

    // Enable/Disable Data Ready Interrupt 1 on Interrupt Pin
    function configureDataReadyInterrupt(state) {
        _setRegBit(CTRL_REG3, 4, state ? 1 : 0);
    }

    // Enables/disables interrupt latching
    function configureInterruptLatching(state) {
        _setRegBit(CTRL_REG5, 1, state ? 1 : 0);
    }

    // Returns interrupt registers as a table, and clears the INT1_SRC register
    function getInterruptTable() {
        local int1 = _getReg(INT1_SRC);
        local click = _getReg(CLICK_SRC);

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


    //-------------------- PRIVATE METHODS --------------------//
    function _twosComp(value, mask) {
        value = ~(value & mask) + 1;
        return value & mask;
    }

    function _getReg(reg) {
        local result = _i2c.read(_addr, reg.tochar(), 1);
        if (result == null) {
            throw "I2C read error: " + _i2c.readerror();
        }
        return result[0];
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

    function dumpRegs() {
        server.log(format("CTRL_REG1 0x%02X", _getReg(CTRL_REG1)));
        server.log(format("CTRL_REG2 0x%02X", _getReg(CTRL_REG2)));
        server.log(format("CTRL_REG3 0x%02X", _getReg(CTRL_REG3)));
        server.log(format("CTRL_REG4 0x%02X", _getReg(CTRL_REG4)));
        server.log(format("CTRL_REG5 0x%02X", _getReg(CTRL_REG5)));
        server.log(format("CTRL_REG6 0x%02X", _getReg(CTRL_REG6)));
        server.log(format("INT1_DURATION 0x%02X", _getReg(INT1_DURATION)));
        server.log(format("INT1_CFG 0x%02X", _getReg(INT1_CFG)));
        server.log(format("INT1_SRC 0x%02X", _getReg(INT1_SRC)));
        server.log(format("INT1_THS 0x%02X", _getReg(INT1_THS)));
    }
}
