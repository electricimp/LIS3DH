
function setUp() {
    _i2c = hardware.i2c89;
    _i2c.configure(CLOCK_SPEED_400_KHZ);
    _intPin = hardware.pin1;
}