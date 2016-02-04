# LIS3DH 3-Axis Accelerometer

The [LIS3DH](http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00274221.pdf) is a 3-Axis MEMS accelerometer. The LIS3DH application note can be found [here](http://www.st.com/web/en/resource/technical/document/application_note/CD00290365.pdf). This sensor has extensive functionality and this class has not yet implemented all of it.

The LPS25H can interface over I&sup2;C or SPI. This class addresses only I&sup2;C for the time being.

<<<<<<< HEAD
To add this library to your project, add #require "LIS3DH.class.nut:1.0.4" to the top of your device code.
=======
**To add this library to your project, add** `#require "LIS3DH.class.nut:1.0.3"` **to the top of your device code**
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119

## Class Usage

### constructor(*i2c[, addr]*)

The class’ constructor takes one required parameter (a configured imp I&sup2;C bus) and an optional parameter (the I&sup2;C address of the accelerometer).  The I&sup2;C address must be the address of your sensor or an I&sup2;C error will be thrown.


| Parameter     | Type         | Default | Description |
| ------------- | ------------ | ------- | ----------- |
| *i2c*           | hardware.i2c | N/A     | A pre-configured I&sup2;C bus |
| *addr*          | byte         | 0x30    | The I&sup2;C address of the accelerometer |

&nbsp;<br>


```squirrel
#require "LIS3DH.class.nut:1.0.4"

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

accel <- LIS3DH(i2c, 0x32); // using a non-default I2C address (SA0 pulled high)
```

## Class Methods

### init()
<<<<<<< HEAD
The *init* method resets all control and interrupt registers to datasheet default values.

```squirrel
accel <- LIS3DH(i2c, 0x32);
accel.init();
```

### setDataRate(*rate_hz*)
The *setDataRate* method sets the Output Data Rate (ODR) of the accelerometer in Hz. Supported datarates are 0 (Shutdown), 1, 10, 25, 50, 100, 200, 400, 1250 (Normal Mode only), 1600 (Low Power Mode only), and 5000 (Low Power Mode only) Hz. The datarate will be rounded up to the closest supported rate and the actual datarate will be returned.

The default datarate is 0 (Shutdown).  To take a reading with *getAccel()* you must set a datarate greater than 0.
=======

The *init()* method resets all registers to datasheet default values. This can be very useful during active development as clicking ‘Build and Run’ will not reset the chip.

```squirrel
i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

accel <- LIS3DH(i2c, 0x32);

// ***REMOVE BEFORE GOING TO PRODUCTION***
accel.reset();
// ***************************************
```

### setDataRate(*rateHz*)

The *setDataRate()* method sets the Output Data Rate (ODR) of the accelerometer in Hz. The nearest supported data rate less than or equal to the requested rate will be used and returned. Supported datarates are 0 (Shutdown), 1, 10, 25, 50, 100, 200, 400, 1600 and 5000Hz.
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119

```squirrel
local rate = accel.setDataRate(100);
server.log(format("Accelerometer running at %d Hz",rate));
```

<<<<<<< HEAD
### setLowPower(*state*)
The *setLowPower* method configures the device to run in low-power or normal mode. The method takes one boolean parameter *state*.  When state is *true* low-power mode will be enabled.  When state is *false* normal mode will enabled. Normal mode guarantees high resolution, low power mode reduces the current consumption.  Higher datarates only support specific modes.  See *setDataRate* for details.

Normal mode is enabled by default.

```Squirrel
// enable low-power mode
accel.setLowPower(true);
```

### enable([*state*])
The *enable* method enables or disables all three axes on the accelerometer. The method takes an optional boolean parameter *state*.  By default *state* is set to true.  When state is *true* the accelerometer will be enabled.  When state is *false* the accelerometer will be disabled.

The accelerometer is enabled by default.

```squirrel
function goToSleep() {
    imp.onidle(function() {
        // set datarate to 0 and disable the accelerometer to save power
        accel.setDataRate(0);
        accel.enable(false);

        // sleep for 1 hour
        server.sleepfor(3600);
    });
}
```

### getAccel([*callback*])
The *getAccel* method reads the latest measurement from the accelerometer.  The method takes an optional callback for asynchronous operation. The callback should take one parameter: a results table (see below). If the callback is null or omitted, the method will return the results table to the caller instead.

| Axis     | Measurement in *G*s |
| -------- | ------------------- |
| x        | x measurement       |
| y        | y measurement       |
| z        | z measurement       |

#####Synchronous Example:

```Squirrel
=======
**Note** The datarate must be set before reading the accelerometer with *getAccel()*.

### getAccel(*[callback]*)

The *getAccel()* method reads and returns the latest measurement from the accelerometer as a table (in Gs):

```squirrel
{ x: <xData>, y: <yData>, z: <zData> }
```

```squirrel
// Create and enable the sensor
i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119
accel.setDataRate(100);

local val = accel.getAccel()
server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", val.x, val.y, val.z));
```

<<<<<<< HEAD
#####Asynchronous Example:

```Squirrel
=======
An optional callback (with a single parameter) can be passed to *getAccel()*. If a callback is included, the class will read the sensor data and pass the result to the callback method as the first parameter:

```squirrel
// Create and enable the sensor
i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119
accel.setDataRate(100);

accel.getAccel(function(val) {
    server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", val.x, val.y, val.z));
});
```

### setRange(*range_g*)
<<<<<<< HEAD
The *setRange* method sets the measurement range of the sensor in *G*s. Supported ranges are (+/-) 2, 4, 8, and 16 G. The datarate will be rounded up to the closest supported range and the actual range will be returned.

The default measurement range is +/- 2G.
=======
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119

The *setRange()* method sets the measurement range of the sensor in Gs. The default measurement range is &plusmn;2G. The nearest supported range less than or equal to the requested range will be used and returned. Supported ranges are (&plusmn;) 2, 4, 6, 8 and 16G.

```squirrel
// Set sensor range to +/- 6 G
local range = accel.setRange(6);
server.log(format("Range set to +/- %d G", range));
```

<<<<<<< HEAD
=======
**Note** If you are not using the default &plusmn;2G range, you must set the range with *setRange()* before setting interrupt thresholds with *setInertialIntThreshold()* or *setClickIntThreshold()*.

>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119
### getRange()

The *getRange()* method returns the currently-set measurement range of the sensor in Gs.

```squirrel
server.log(format("Current Sensor Range is +/- %d G", accel.getRange()));
```

### configureInertialInterrupt(*state[, threshold][, duration][, options]*)

Configures the Inertial Interrupt generator:

| parameter | type     | default                    | description |
| --------- | -------- | -------------------------- | ----------- |
| state     | bool     | n/a                        | `true` to enable, `false` to disable |
| threshold | float    | 2.0                        | Inertial interrupts threshold in Gs |
| duration  | int      | 5                          | Number of samples exceeding threshold required to generate interrupt |
| options   | bitfield | *X_HIGH* \| *Y_HIGH* \| *Z_HIGH* | See table below |

```squirrel
// Configure the Inertial interrupt generator to generate an interrupt
// when acceleration on all three exceeds 1G.
accel.configureInertialInterrupt(true, 1.0, 10, LIS3DH.X_LOW | LIS3DH.Y_LOW | LIS3DH.Z_LOW | LIS3DH.AOI)
```

<<<<<<< HEAD
The default configuration for the Intertial Interrupt generator is to generate an interrupt when the acceleration on *any* axis exceeds 2G. This behavior can be changed by OR'ing together any of the following flags:

| flag   | description |
| ------ | ----------- |
| X_LOW  | Generates an interrupt when the x-axis acceleration goes below the threshold |
| X_HIGH | Generates an interrupt when the x-axis acceleration goes above the threshold |
| Y_LOW  | Generates an interrupt when the y-axis acceleration goes below the threshold |
| Y_HIGH | Generates an interrupt when the y-axis acceleration goes above the threshold |
| Z_LOW  | Generates an interrupt when the z-axis acceleration goes below the threshold |
| Z_HIGH | Generates an interrupt when the z-axis acceleration goes above the threshold |
| AOI    | Sets the AOI flag (see **Inertial Interrupt Modes** below) |
| SIX_D  | Sets the 6D flag (see **Inertial Interrupt Modes** below) |
=======
The default configuration for the Intertial Interrupt generator is to generate an interrupt when the acceleration on *any* axis exceeds 1G. This behavior can be changed by OR-ing together any of the following flags:

| flag   | description |
| ------ | ----------- |
| *X_LOW*  | Generates an interrupt when the x-axis acceleration goes below the threshold |
| *X_HIGH* | Generates an interrupt when the x-axis acceleration goes above the threshold |
| *Y_LOW*  | Generates an interrupt when the y-axis acceleration goes below the threshold |
| *Y_HIGH* | Generates an interrupt when the y-axis acceleration goes above the threshold |
| *Z_LOW*  | Generates an interrupt when the z-axis acceleration goes below the threshold |
| *Z_HIGH* | Generates an interrupt when the z-axis acceleration goes above the threshold |
| *AOI*    | Sets the AOI flag *(see ‘Inertial Interrupt Modes’ below)* |
| *SIX_D*  | Sets the 6D flag *(see ‘Inertial Interrupt Modes’ below)* |
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119

#### Inertial Interrupt Modes

The following is taken from the from [LIS3DH Datasheet](http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00274221.pdf) (section 8.21):

| AOI | 6D  | Interrupt Mode                     |
| --- | --- | ---------------------------------- |
|  0  |  0  | OR combination of interrupt events |
|  0  |  1  | 6-direction movement recognition   |
|  1  |  0  | AND combination of events          |
|  1  |  1  | 6-direction position recognition   |

**Movement Recognition (01)** An interrupt is generate when orientation move from unknown zone to known zone. The interrupt signal stay for a duration ODR.

**Direction Recognition (11)** An interrupt is generate when orientation is inside a known zone. The interrupt signal stay until orientation is inside the zone.

### configureFreeFallInterrupt(*state[, threshold][, duration]*)

The *configureFreeFallInterrupt()* method configures the intertial interrupt generator to generate interrupts when the device is in free fall (acceleration on all axis appraoches 0). The default *threshold* is 0.5 Gs.The default *duration* is five samples.

```squirrel
accel.configureFreeFallInterrupt(true);
```

**Note** This method will overwrite any settings configured with the *configureInertialInterrupt()*.

### configureClickInterrupt(*state[, clickType][, threshold][, timeLimit][, latency][, window]*)

Configures the Click Interrupt Generator:

| parameter | type       | default                    | description                                              |
| --------- | ---------- | -------------------------- | -------------------------------------------------------- |
| *state*     | bool       | n/a                        | `true` to enable, `false` to disable                     |
| *clickType* | CONST      | *LIS3DH.SINGLE_CLICK*        | *LIS3DH.SINGLE_CLICK* or *LIS3DH.DOUBLE_CLICK*               |
| *threshold* | float      | 1.1                        | Threshold that must be exceeded to be considered a click |
| *timeLimit* | float      | 5                          | Max time in *ms* the acceleration can spend above the threshold to be considered a click |
| *latency*   | float      | 10                         | Min time in *ms* between the end of one click event, and the start of another to be considred a *LIS3DH.DOUBLE_CLICK* |
| *window*    | float      | 50                         | Max time in *ms* between the start of one click event, and end of another to be considered a *LIS3DH.DOUBLE_CLICK* |

#### Single Click example

```squirrel
// Configure a single click interrupt
accel.configureClickInterrupt(true, LIS3DH.SINGLE_CLICK);
```

#### Double Click Example

```squirrel
// configure a double click interrupt
accel.configureClickInterrupt(true, LIS3DH.DOUBLE_CLICK);
```

### configureDataReadyInterrupt(*state*)

Enables (*state* is `true`) or disables (*state* is `false`) Data Ready interrupts on the INT1 line.

```squirrel
accel.setDataRate(1); // 1 Hz
accel.configureDataReadyInterrupt(true);
```

### configureInterruptLatching(*state*)

<<<<<<< HEAD
=======
Enables (*state* is `true`) or disables (*state* is `false`) interrupt latching. If interrupt latching is enabled, the interrupt signal will remain asserted until the interrupt source register is read by calling *getInterruptTable()*. If latching is disabled, the interrupt signal will remain asserted as long as the interrupt-generating condition persists.

>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119
Inertial and free fall are the only interrupts compatible with latching mode.

Interrupt latching is disabled by default.

*See sample code in getInterruptTable()*

### getInterruptTable()

The *getInterruptTable()* method reads the *INT1_SRC* and *CLICK_SRC* registers, and returns the result as a table with the following fields:

```squirrel
{
    "int1": bool,           // true if INT1 created the interrupt
    "xLow": bool,           // true if a xLow condition is present
    "yLow": bool,           // true if a yLow condition is present
    "zLow": bool,           // true if a zLow condition is present
    "xHigh": bool,          // true if a xHigh condition is present
    "yHigh": bool,          // true if a yHigh condition is present
    "zHigh": bool,          // true if a zHigh condition is present
    "click": bool,          // true if any click created the interrupt
    "singleClick": bool,    // true if a single click created the interrupt
    "doubleClick": bool     // true if a double click created the interrupt
}
```

In the following example we setup an interrupt for double click detection:

```squirrel
function interruptHandler() {
    if (int.read() == 0) return;

    // Get + clear the interrupt + clear
    local data = accel.getInterruptTable();

    // Check what kind of interrupt it was
    if (data.doubleClick) {
        server.log("Double Click");
    }
}

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);

int <- hardware.pinB;
int.configure(DIGITAL_IN, interruptHandler);

// Configure accelerometer
accel.setDataRate(100);

// Set up a double-click interrupt
accel.configureClickInterrupt(true, LIS3DH.DOUBLE_CLICK);
```

In the following example we setup an interrupt for free fall detection:

```squirrel
function sensorSetup() {
    // Configure accelerometer
    accel.setDataRate(100);
    accel.configureInterruptLatching(true);

    // Setup a free fall interrupt
    accel.configureFreeFallInterrupt(true);
}

// Put imp to Sleep
function sleep(timer) {
    server.log("going to sleep for " + timer + " sec");
    if (server.isconnected()) {
        imp.onidle(function() { server.sleepfor(timer); });
    } else {
        imp.deepsleepfor(timer);
    }
}

// Take reading
function takeReading() {
    accel.getAccel(function(result) {
        if ("err" in result) {
            // check for error
            server.log(result.err);
        } else {
            // add timestamp to result table
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
    if (data.int1) {
        server.log("Free Fall");
    }
    sleep(30);
}

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);

int <- hardware.pinB;
wake <- hardware.pin1;

int.configure(DIGITAL_IN);
wake.configure(DIGITAL_IN_WAKEUP);

// Handle WakeUp
switch(hardware.wakereason()) {
    case WAKEREASON_TIMER:
        server.log("WOKE UP B/C TIMER EXPIRED");
        takeReading();
        imp.wakeup(2, function() { sleep(30); })
        break;
    case WAKEREASON_PIN:
        server.log("WOKE UP B/C PIN HIGH");
        interruptHandler();
        break;
    default:
        server.log("WOKE UP B/C RESTARTED DEVICE, LOADED NEW CODE, ETC");
        sensorSetup();
        takeReading();
        imp.wakeup(2, function() { sleep(30); })
}
```

### getDeviceId()

Returns the one-byte device ID of the sensor (from the *WHO_AM_I* register). The *getDeviceId()* method is a simple way to test if your LIS3DH sensor is correctly connected.

```squirrel
server.log(format("Device ID: 0x%02X", accel.getDeviceId()));
```

<<<<<<< HEAD
=======
### enable(*state*)

The *enable()* methods enables (*state* is `true`) or disabled (*state* is `false`) the accelerometer. The accelerometer is enabled by default.

```squirrel
function goToSleep() {
    imp.onidle(function() {
        // Set data rate to 0 and disable the accelerometer to save power
        accel.setDataRate(0);
        accel.enable(false);

        // Sleep for 1 hour
        server.sleepfor(3600);
    });
}
```

### setLowPower(*state*)

The *setLowPower()* method enables (*state* is `true`) or disables (*state* is `false`) low-power mode.

```squirrel
// Enable low-power mode
accel.setLowPower(true);
```
>>>>>>> 0f6e789c59ec6bb5d2aaa988c60d49a2d5b69119

**Note** *setLowPower()* will change the data rate.

## License

The LIS3DH class is licensed under [MIT License](https://github.com/electricimp/lis3dh/blob/master/LICENSE).
