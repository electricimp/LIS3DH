# LIS3DH 3-Axis Accelerometer #

[![Build Status](https://api.travis-ci.org/electricimp/LIS3DH.svg?branch=master)](https://travis-ci.org/electricimp/LIS3DH)

The [LIS3DH](http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00274221.pdf) is a three-axis MEMS accelerometer. The LIS3DH application note can be found [here](http://www.st.com/web/en/resource/technical/document/application_note/CD00290365.pdf). This sensor has extensive functionality and this class has not yet implemented all of it. The LIS3DH can interface over I&sup2;C or SPI. This class addresses only I&sup2;C for the time being.

This library also supports the LIS2DH12, another widely used three-axis MEMS accelerometer and which can be found on [Electric Imp’s impExplorer&trade; Kit](https://developer.electricimp.com/gettingstarted/devkits).

**To add this library to your project, add** `#require "LIS3DH.device.lib.nut:2.0.2"` **to the top of your device code**

## Class Usage ##

### Constructor: LIS3DH(*i2cBus[, i2cAddress]*) ###

The class’ constructor takes one required parameter (a configured imp I&sup2;C bus) and an optional parameter (the I&sup2;C address of the accelerometer). The I&sup2;C address must be the address of your sensor or an I&sup2;C error will be thrown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| *i2cBus* | hardware.i2c | N/A | A pre-configured I&sup2;C bus |
| *i2cAddress* | byte | 0x30 | The I&sup2;C address of the accelerometer |

```squirrel
i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

// Use a non-default I2C address (SA0 pulled high)
accel <- LIS3DH(i2c, 0x32);
```

## Class Methods ##

### reset() ###

This method resets all control and interrupt registers to datasheet default values. This method need only be called to restore registers to these default conditions.

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.reset();
```

### setDataRate(*rateInHz*) ###

This method sets the Output Data Rate (ODR) of the accelerometer in Hertz. Supported data rates are 0 (Shutdown), 1, 10, 25, 50, 100, 200, 400, 1250 (Normal Mode only), 1600 (Low-Power Mode only) and 5000 (Low-Power Mode only). The requested data rate will be rounded up to the closest supported rate and the actual data rate will be returned.

The default data rate is 0 (Shutdown). To take a reading with *getAccel()* you must set a data rate greater than 0.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *rateInHz* | Integer | Yes | The required Output Data Rate (ODR) of the accelerometer in Hertz |

#### Return Value ####

Integer &mdash; the actual data rate.

#### Example ####

```squirrel
local rate = accel.setDataRate(90);
server.log(format("Accelerometer running at %dHz", rate));
// Displays 'Accelerometer running at 100Hz'
```

### setMode(*mode*) ###

This method sets the accelerometer into low power, normal or high resolution mode. The method takes one of three mode constants: *LIS3DH_MODE_NORMAL*, *LIS3DH_MODE_LOW_POWER* or *LIS3DH_MODE_HIGH_RESOLUTION*. The default mode is *LIS3DH_MODE_NORMAL*.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *mode* | Integer | Yes | The required accelerometer mode |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.setMode(LIS3DH_MODE_HIGH_RESOLUTION);
```

### enableADC(*state*) ###

This method enables the three ADC lines available to the LIS3DH (the LIS2DH does not have these auxiliary lines available). Its input ranges from approximately 0.8-1.6V. By default, the ADC is disabled.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | Sets the ADC on (`true`) or off (`false`) |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.enableADC(true);
```

### readADC(*line*) ###

The *readADC()* method returns a reading from approximately 0.8-1.6V from the specified ADC line. The required line, one of three, is set by providing one the following constants: *LIS3DH_ADC1*, *LIS3DH_ADC2* or *LIS3DH_ADC3*. The ADC must first be enabled by calling `enableADC(true)`.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *line* | Integer | Yes | The ADC line |

#### Return Value ####

Float &mdash; the reading from the selected ADC line.

#### Example ####

```squirrel
accel.enableADC(true);
local reading = accel.readADC(LIS3DH_ADC1);
```

### enable(*[state]*) ###

This method enables or disables all three axes on the accelerometer. Calling the method without an argument enables the accelerometer. When *state* is `false`, the accelerometer will be disabled.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | No | Activate (`true`) or disable (`false`) the accelerometer is active (Default: `true`) |

#### Return Value ####

Nothing.

#### Example ####

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

### getAccel(*[callback]*) ###

This method reads the latest measurement from the accelerometer. It takes an optional callback for asynchronous operation &mdash; it will block otherwise. The callback should take one parameter: a results table *(see below)*. If the callback is `null` or omitted, the method will return the results table.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *callback* | Function | No | Function called with the accelerometer reading as its only argument (see below) |

#### Return Value ####

Table &mdash; the latest reading from the accelerometer as values to the keys *x*, *y* and *z*. **Note** if *getAccel()* is called with an argument, it will return nothing.

#### Synchronous Example ####

```squirrel
accel.setDataRate(100);
local val = accel.getAccel();
server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", val.x, val.y, val.z));
```

#### Asynchronous Example ####

```squirrel
accel.setDataRate(100);
accel.getAccel(function(val) {
  server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", val.x, val.y, val.z));
});
```

### setRange(*range*) ###

This method sets the measurement range of the sensor in Gs. Supported ranges are &plusmn;2, &plusmn;4, &plusmn;8 and &plusmn;16G. The data rate will be rounded up to the closest supported range and the actual range will be returned. The default measurement range is &plusmn;2G.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *range* | Integer | Yes | The measurement range of the sensor in Gs |

#### Return Value ####

Integer &mdash; the current measurement range.

#### Example ####

```squirrel
// Set sensor range to +/- 8G
local range = accel.setRange(8);
server.log(format("Range set to +/- %dG", range));
```

### getRange() ###

This method returns the currently-set measurement range of the sensor in Gs.

#### Return Value ####

Integer &mdash; the current measurement range.

```
server.log(format("Current Sensor Range is +/- %dG", accel.getRange()));
```

### configureFifoInterrupt(*state[, fifomode][, watermark]*) ###

This method configures an interrupt when the FIFO buffer reaches the set watermark.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | FIFO state: `true` to enable, `false` to disable |
| *fifomode* | Bitfield | No | See table below (Default: *LIS3DH_FIFO_STREAM_MODE*) |
| *watermark* | Integer | No | Number of buffer slots filled to generate interrupt (buffer has 32 slots; default: 28) |

#### FIFO Modes ####

| Mode | Description |
| --- | --- |
| *LIS3DH_FIFO_BYPASS_MODE* | Disables the FIFO buffer (only the first address is used for each channel) |
| *LIS3DH_FIFO_FIFO_MODE* | When full, the FIFO buffer stops collecting data from the input channels |
| *LIS3DH_FIFO_STREAM_MODE* | When full, the FIFO buffer discards the older data as the new arrive |
| *LIS3DH_FIFO_STREAM_TO_FIFO_MODE* | When full, the FIFO buffer discards the older data as the new arrive. Once trigger event occurs, the FIFO buffer starts operating in FIFO mode |

#### Return Value ####

Nothing.

#### Example ####

This example sets the FIFO buffer to Stream Mode and reads the data from the buffer whenever the watermark is reached:

```squirrel
// Function to read from FIFO buffer
function readBuffer() {
  if (wakePin.read() == 0) return;

  // Read buffer
  local stats = accel.getFifoStats();
  for (local i = 0 ; i < stats.unread ; i++) {
    local data = accel.getAccel();
    server.log(format("Accel (x,y,z): [%d, %d, %d]", data.x, data.y, data.z));
  }

  // Check if we are now over-run
  local stats = accel.getFifoStats();
  if (stats.overrun) {
    server.error("Accelerometer buffer over-run");

    // Set FIFO mode to bypass to clear the buffer and then return to stream mode
    accel.configureFifoInterrupt(true, LIS3DH_FIFO_BYPASS_MODE);
    accel.configureFifoInterrupt(true, LIS3DH_FIFO_STREAM_MODE, 30);
  }
}

i2c <- hardware.i2cAB;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c);

// Configure interrupt pin
wakePin <- hardware.pinW;
wakePin.configure(DIGITAL_IN_PULLDOWN, readBuffer);

// Configure accelerometer
accel.setDataRate(100);

// Configure the FIFO buffer in Stream Mode and set interrupt generator
// to generate an interrupt when there are 30 entries in the buffer
accel.configureFifoInterrupt(true, LIS3DH_FIFO_STREAM_MODE, 30);
```

### configureInertialInterrupt(*state[, threshold][, duration][, options]*) ####

This method configures the inertial interrupt generator.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *threshold* | Float | No | Inertial interrupts threshold in Gs (Default: 2.0) |
| *duration* | Integer | No | Number of samples exceeding threshold<br>required to generate interrupt (Default: 5) |
| *options* | Bitfield | No | See table below (Default: *LIS3DH_X_HIGH* \| *LIS3DH_Y_HIGH* \| *LIS3DH_Z_HIGH*) |

The default configuration for the Intertial Interrupt generator is to generate an interrupt when the acceleration on *any* axis exceeds 2G. This behavior can be changed by OR-ing together any of the following flags:

| Flag | Description |
| --- | --- |
| *LIS3DH_X_LOW*  | Generates an interrupt when the x-axis acceleration goes below the threshold |
| *LIS3DH_X_HIGH* | Generates an interrupt when the x-axis acceleration goes above the threshold |
| *LIS3DH_Y_LOW*  | Generates an interrupt when the y-axis acceleration goes below the threshold |
| *LIS3DH_Y_HIGH* | Generates an interrupt when the y-axis acceleration goes above the threshold |
| *LIS3DH_Z_LOW*  | Generates an interrupt when the z-axis acceleration goes below the threshold |
| *LIS3DH_Z_HIGH* | Generates an interrupt when the z-axis acceleration goes above the threshold |
| *LIS3DH_AOI*    | Sets the AOI flag *(see ‘Inertial Interrupt Modes’ below)* |
| *LIS3DH_SIX_D*  | Sets the 6D flag *(see ‘Inertial Interrupt Modes’ below)* |

#### Inertial Interrupt Modes ####

The following is taken from the from [LIS3DH Datasheet](http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00274221.pdf) (section 8.21):

| AOI | 6D | Interrupt Mode |
| --- | --- | --- |
|  0  |  0  | OR combination of interrupt events |
|  0  |  1  | 6-direction movement recognition |
|  1  |  0  | AND combination of events |
|  1  |  1  | 6-direction position recognition |

**Movement Recognition (01)** An interrupt is generate when orientation move from unknown zone to known zone. The interrupt signal stay for a duration ODR.

**Direction Recognition (11)** An interrupt is generate when orientation is inside a known zone. The interrupt signal stay until orientation is inside the zone.

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// Configure the Inertial interrupt generator to generate an interrupt
// when acceleration on all three exceeds 1G.
accel.configureInertialInterrupt(true, 1.0, 10, LIS3DH_X_LOW | LIS3DH_Y_LOW | LIS3DH_Z_LOW | LIS3DH_AOI)
```

### configureFreeFallInterrupt(*state[, threshold][, duration]*) ###

This method configures the intertial interrupt generator to generate interrupts when the device is in free fall, ie. acceleration on all axis approaches 0.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *threshold* | Float | No | Inertial interrupts threshold in Gs (Default: 0.5) |
| *duration* | Integer | No | Number of samples exceeding threshold required to generate interrupt (Default: 5) |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.configureFreeFallInterrupt(true);
```

**Note** This method will overwrite any settings configured with *configureInertialInterrupt()*.

### configureClickInterrupt(*state[, clickType][, threshold][, timeLimit][, latency][, window]*) ###

This method configures the click interrupt generator.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *clickType* | Integer | No | *LIS3DH_SINGLE_CLICK* or *LIS3DH_DOUBLE_CLICK* (Default: *LIS3DH_SINGLE_CLICK*) |
| *threshold* | Float | No | Inertial interrupts threshold in Gs (Default: 1.1) |
| *timeLimit* | Float | No | Maximum time in milliseconds the acceleration can spend above the threshold to be considered a click (Default: 5) |
| *latency* | Float | No | Minimum time in milliseconds between the end of one click event and the start of another to be considered a *LIS3DH_DOUBLE_CLICK* (Default: 10) |
| *window* | Float | o | Maximum time in milliseconds between the start of one click event and end of another to be considered a *LIS3DH_DOUBLE_CLICK* (Default: 50) |

#### Return Value ####

Nothing.

#### Single Click Example ####

```squirrel
// Configure a single click interrupt
accel.configureClickInterrupt(true, LIS3DH_SINGLE_CLICK);
```

#### Double Click Example ####

```squirrel
// configure a double click interrupt
accel.configureClickInterrupt(true, LIS3DH_DOUBLE_CLICK);
```

### configureDataReadyInterrupt(*state*) ###

This method enables (*state* is `true`) or disables (*state* is `false`) data-ready interrupts on the sensor’s INT1 line. The data-ready signal rises to 1 when a new set of acceleration data has been generated and it is available for reading. The interrupt is reset when the higher part of the data of all the enabled channels has been read.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.setDataRate(1); // 1Hz
accel.configureDataReadyInterrupt(true);
```

### configureInterruptLatching(*state*) ###

Enables (*state* is `true`) or disables (*state* is `false`) interrupt latching. If interrupt latching is enabled, the interrupt signal will remain asserted until the interrupt source register is read by calling *getInterruptTable()*. If latching is disabled, the interrupt signal will remain asserted as long as the interrupt-generating condition persists.

Interrupt latching is disabled by default.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The latching state: `true` to enable, `false` to disable |

#### Return Value ####

Nothing.

#### Example ####

For an example, see the sample code under *getInterruptTable()*, below.

### getInterruptTable() ###

This method reads the LIS3DH’s *INT1_SRC* and *CLICK_SRC* registers.

#### Return Value ####

Table &mdash; the interrupt settings:

| Key | Type | Description |
| --- | --- | --- |
| *int1* | Bool | `true` if INT1 created the interrupt |
| *xLow* | Bool | `true` if a xLow condition is present |
| *yLow* | Bool | `true` if a yLow condition is present |
| *zLow* | Bool | `true` if a zLow condition is present |
| *xHigh* | Bool | `true` if a xHigh condition is present |
| *yHigh* | Bool | `true` if a yHigh condition is present |
| *zHigh* | Bool | `true` if a zHigh condition is present |
| *click* | Bool | `true` if any click created the interrupt |
| *singleClick* | Bool | `true` if a single click created the interrupt |
| *doubleClick* | Bool | `true` if a double click created the interrupt |

#### Example ####

In the following example we set up an interrupt for double-click detection:

```squirrel
function interruptHandler() {
  if (int.read() == 0) return;

  // Get + clear the interrupt + clear
  local data = accel.getInterruptTable();

  // Check what kind of interrupt it was
  if (data.doubleClick) server.log("Double Click");
}

i2c <- hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);
accel <- LIS3DH(i2c, 0x32);

int <- hardware.pinB;
int.configure(DIGITAL_IN, interruptHandler);

// Configure accelerometer
accel.setDataRate(100);

// Set up a double-click interrupt
accel.configureClickInterrupt(true, LIS3DH_DOUBLE_CLICK);
```

In the following example we setup an interrupt for free-fall detection:

```squirrel
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
  if (data.int1) server.log("Free Fall");

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
```

### getFifoStats() ###

This method returns information about the state of the FIFO buffer.

#### Return Value ####

Table &mdash; the FIFO buffer state:

| Key | Type | Description |
| --- | --- | --- |
| *watermark* | Boolean | `true` if watermark has been set |
| *overrun* | Boolean | `true` if data has been overwritten without being read |
| *empty* | Boolean | `true` if buffer is empty |
| *unread* | Integer | Number of unread slots in buffer |

### configureHighPassFilter(*filters[, cutoff][, mode]*) ###

This method configures the high-pass filter.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *filters* | Integer | Yes | Select the filter(s) to enable/disable by OR-ing together any of the constants found in the filters table below |
| *cutoff* | Integer | No | See high-pass filter cut-off frequency table below (Default: *LIS3DH_HPF_CUTOFF1*) |
| *mode* | Integer | No | See modes table below (Default: *LIS3DH_HPF_DEFAULT_MODE*) |

#### Filters ####

| Filter Constant | Description |
| --- | --- |
| *LIS3DH_HPF_AOI_INT1* | High-pass filter enabled for AOI function on interrupt 1 |
| *LIS3DH_HPF_AOI_INT2* | High-pass filter enabled for AOI function on interrupt 2 |
| *LIS3DH_HPF_CLICK* | High-pass filter enabled for CLICK function |
| *LIS3DH_HPF_FDS* | Filtered data selection. Enables data from internal filter sent to output register and FIFO |
| *LIS3DH_HPF_DISABLED* | Disables all filters |

#### High-pass Filter Cut-off Frequencies ####

| Cut-off Constant | f@1Hz | f@10Hz | f@25Hz | f@50Hz | f@100Hz | f@200Hz | f@400Hz | f@1600Hz | f@5000Hz |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| *LIS3DH_HPF_CUTOFF1* | 0.02 | 0.2 | 0.5 | 1 | 2 | 4 | 8 | 32 | 100 |
| *LIS3DH_HPF_CUTOFF2* | 0.008 | 0.08 | 0.2 | 0.5 | 1 | 2 | 4 | 16 | 50 |
| *LIS3DH_HPF_CUTOFF3* | 0.004 | 0.04 | 0.1 | 0.2 | 0.5 | 1 | 2 | 8 | 25 |
| *LIS3DH_HPF_CUTOFF4* | 0.002 | 0.02 | 0.05 | 0.1 | 0.2 | 0.5 | 1 | 4 | 12 |

#### Modes ####

| Mode Constant | Description |
| --- | --- |
| *LIS3DH_HPF_DEFAULT_MODE* | Normal mode (reset reading *HP_RESET_FILTER*) |
| *LIS3DH_HPF_REFERENCE_SIGNAL* | Reference signal for filtering |
| *LIS3DH_HPF_NORMAL_MODE* | Normal mode |
| *LIS3DH_HPF_AUTORESET_ON_INTERRUPT* | Autoreset on interrupt event |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
// Enable high-pass filter on click and intertial interrupt 1 with auto reset on interrupt event
accel.configureHighPassFilter(LIS3DH_HPF_AOI_INT1 | LIS3DH_HPF_CLICK, null, LIS3DH_HPF_AUTORESET_ON_INTERRUPT);

// Disable high pass filter
accel.configureHighPassFilter(LIS3DH_HPF_DISABLED);
```

### getDeviceId() ###

This method returns the one-byte device ID of the sensor (from the *WHO_AM_I* register). The *getDeviceId()* method is a simple way to test if your LIS3DH sensor is correctly connected.

#### Return Value ####

Integer &mdash; single-byte device ID.

#### Example ####

```
server.log(format("Device ID: 0x%02X", accel.getDeviceId()));
```

## License ##

The LIS3DH class is licensed under [MIT License](./LICENSE).
