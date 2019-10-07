# LIS3DH 3.0.0 #

The [LIS3DH](http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/CD00274221.pdf) is a three-axis MEMS accelerometer. The LIS3DH application note can be found [here](http://www.st.com/web/en/resource/technical/document/application_note/CD00290365.pdf). This sensor has extensive functionality and this class has not yet implemented all of it. The LIS3DH can interface over I&sup2;C or SPI; this library addresses only I&sup2;C.

All interrupt functions in the current library are configured for interrupt 1 only. There is no support for settings or control on interrupt 2.

This library also supports the LIS2DH12, another widely used three-axis MEMS accelerometer and which can be found on [Electric Imp’s impExplorer&trade; Kit](https://developer.electricimp.com/gettingstarted/devkits).

**To include this library in your project, add** `#require "LIS3DH.device.lib.nut:3.0.0"` **at the top of your device code**

![Build Status](https://cse-ci.electricimp.com/app/rest/builds/buildType:(id:Lis3dh_BuildAndTest)/statusIcon)

## Class Usage ##

### Constructor: LIS3DH(*i2cBus[, i2cAddress]*) ###

The class’ constructor takes one required parameter (a configured imp I&sup2;C bus) and an optional parameter (the I&sup2;C address of the accelerometer). The I&sup2;C address must be the address of your sensor or an I&sup2;C error will be thrown.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *i2cBus* | hardware.i2c | Yes | A pre-configured I&sup2;C bus |
| *i2cAddress* | byte | No | The I&sup2;C address of the accelerometer. Default: `0x30` |

```squirrel
#require "LIS3DH.device.lib.nut:3.0.0"

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

| Parameter | Type | Required? | Description |
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

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *mode* | Integer | Yes | The required accelerometer mode |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.setMode(LIS3DH_MODE_HIGH_RESOLUTION);
```

### enable(*[state]*) ###

This method enables or disables all three axes on the accelerometer. Calling the method without an argument enables the accelerometer. When *state* is `false`, the accelerometer will be disabled.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | No | Activate (`true`) or disable (`false`) the accelerometer. Default: `true` |

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

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *callback* | Function | No | Function called with the accelerometer reading as its only argument. The reading is a table as described in **Return Value**, below |

#### Return Value ####

Table &mdash; The latest reading from the accelerometer as a table with slots *x*, *y* and *z*, or just *error* if an I&sup2;C error was encountered. **Note** if *getAccel()* is called with an argument, it will return nothing.

#### Synchronous Example ####

```squirrel
accel.setDataRate(100);
local reading = accel.getAccel();
if ("error" in reading) {
    server.error(reading.error);
} else {
    server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", reading.x, reading.y, reading.z));
}
```

#### Asynchronous Example ####

```squirrel
accel.setDataRate(100);
accel.getAccel(function(reading) {
    if ("error" in reading) {
        server.error(reading.error);
    } else {
        server.log(format("Acceleration (G): (%0.2f, %0.2f, %0.2f)", reading.x, reading.y, reading.z));
    }
});
```

### setRange(*range*) ###

This method sets the measurement range of the sensor in Gs. Supported ranges are &plusmn;2, &plusmn;4, &plusmn;8 and &plusmn;16G. The data rate will be rounded up to the closest supported range and the actual range will be returned. The default measurement range is &plusmn;2G.

#### Parameters ####

| Parameter | Type | Required? | Description |
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

### enableADC(*state*) ###

This method enables the three ADC lines available to the LIS3DH (the LIS2DH does not have these auxiliary lines available). Its input ranges from approximately 0.8-1.6V. By default, the ADC is disabled.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | Sets the ADC on (`true`) or off (`false`) |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.enableADC(true);
```

### readADC(*line*) ###

This method returns a reading from approximately 0.8-1.6V from the specified ADC line. The required line, one of three, is set by providing one the following constants: *LIS3DH_ADC1*, *LIS3DH_ADC2* or *LIS3DH_ADC3*. The ADC must first be enabled by calling `enableADC(true)`.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *line* | Integer | Yes | The ADC line |

#### Return Value ####

Float &mdash; the reading from the selected ADC line.

#### Example ####

```squirrel
accel.enableADC(true);
local reading = accel.readADC(LIS3DH_ADC1);
```

### getDeviceId() ###

This method returns the one-byte device ID of the sensor (from the *WHO_AM_I* register). The *getDeviceId()* method is a simple way to test if your LIS3DH sensor is correctly connected.

#### Return Value ####

Integer &mdash; single-byte device ID.

#### Example ####

```squirrel
server.log(format("Device ID: 0x%02X", accel.getDeviceId()));
```

### configureHighPassFilter(*filters[, cutoff][, mode]*) ###

This method configures the high-pass filter.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *filters* | Integer | Yes | Select the filter(s) to enable/disable by OR-ing together any of the constants found under [**Filters**](#filters), below |
| *cutoff* | Integer | No | See [**High-pass Filter Cut-off Frequencies**](#high-pass-filter-cut-off-frequencies), below. Default: *LIS3DH_HPF_CUTOFF1* |
| *mode* | Integer | No | See [**Modes**](#modes), below. Default: *LIS3DH_HPF_DEFAULT_MODE* |

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
// Enable high-pass filter on click and inertial interrupt 1 with auto reset on interrupt event
accel.configureHighPassFilter(LIS3DH_HPF_AOI_INT1 | LIS3DH_HPF_CLICK,
                              null,
                              LIS3DH_HPF_AUTORESET_ON_INTERRUPT);

// Disable high pass filter
accel.configureHighPassFilter(LIS3DH_HPF_DISABLED);
```

### configureFifo(*enableBuffer[, mode]*) ###

This method enables/disables the FIFO buffer and configures its mode.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *enableBuffer* | Boolean | Yes | Whether to enable (`true`) or disable (`false`) the Fifo buffer |
| *mode* | Bitfield | No | See [**FIFO Modes**](#fifo-modes), below. Default: *LIS3DH_FIFO_STREAM_MODE* |

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

```
// Enable the FIFO buffer in LIS3DH_FIFO_STREAM_TO_FIFO_MODE
accel.configureFifo(true, LIS3DH_FIFO_STREAM_TO_FIFO_MODE);
```

### configureFifoInterrupts(*enableWatermark[, enableOverrun][, watermark]*) ###

This method enables/disables FIFO watermark and overrun interrupts. Please note the FIFO buffer must be enabled for the interrupt to work properly.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *enableWatermark* | Boolean | Yes | Whether to enable (`true`) or disable (`false`) the FIFO watermark interrupt |
| *enableOverrun* | Boolean | No | Whether to enable (`true`) or disable (`false`) the FIFO overrun interrupt Default: `false` |
| *watermark* | Integer | No | Number of buffer slots filled to generate interrupt. Buffer has 32 slots. Default: 29 |

#### Example ####

```squirrel
// Configure the FIFO buffer in Stream Mode and set interrupt generator
// to generate an interrupt when there are 30 entries in the buffer
accel.configureFifo(true);
accel.configureFifoInterrupts(true, false, 30);
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

#### Example ####

```squirrel
local fifoStatus = accel.getFifoStats();
local numUnreadReadings = fifoStatus.unread;
for (local i = 0; i < numUnreadReadings; i++) {
    local reading = accel.getAccel();
    server.log(format("Accel (x,y,z): [%d, %d, %d]", data.x, data.y, data.z));
}
```

### configureInterruptLatching(*state*) ###

Enables (*state* is `true`) or disables (*state* is `false`) interrupt latching. If interrupt latching is enabled, the interrupt signal will remain asserted until the interrupt source register is read by calling *getInterruptTable()*. If latching is disabled, the interrupt signal will remain asserted as long as the interrupt-generating condition persists.

Interrupt latching is disabled by default.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The latching state: `true` to enable, `false` to disable |

#### Return Value ####

Nothing.

#### Example ####

```
// Configure interrupt pin to latch
accel.configureInterruptLatching(true);
```

### configureInertialInterrupt(*state[, threshold][, duration][, options]*) ####

This method configures the inertial interrupt generator.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *threshold* | Float | No | Inertial interrupts threshold in Gs. Default: 2.0 |
| *duration* | Integer | No | Number of samples exceeding threshold required to generate interrupt. Default: 5 |
| *options* | Bitfield | No | See [**Option Flags**](#option-flags), below. Default: *LIS3DH_X_HIGH* \| *LIS3DH_Y_HIGH* \| *LIS3DH_Z_HIGH*) |

The default configuration for the Inertial Interrupt generator is to generate an interrupt when the acceleration on *any* axis exceeds 2G. This behavior can be changed by OR-ing together any of the following flags:

#### Option Flags ####

| Flag | Description |
| --- | --- |
| *LIS3DH_X_LOW*  | Generates an interrupt when the x-axis acceleration goes below the threshold |
| *LIS3DH_X_HIGH* | Generates an interrupt when the x-axis acceleration goes above the threshold |
| *LIS3DH_Y_LOW*  | Generates an interrupt when the y-axis acceleration goes below the threshold |
| *LIS3DH_Y_HIGH* | Generates an interrupt when the y-axis acceleration goes above the threshold |
| *LIS3DH_Z_LOW*  | Generates an interrupt when the z-axis acceleration goes below the threshold |
| *LIS3DH_Z_HIGH* | Generates an interrupt when the z-axis acceleration goes above the threshold |
| *LIS3DH_AOI*    | Sets the AOI flag (see [**Inertial Interrupt Modes**](#inertial-interrupt-modes), below) |
| *LIS3DH_SIX_D*  | Sets the 6D flag (see [**Inertial Interrupt Modes**](#inertial-interrupt-modes), below) |

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
// when acceleration on all three exceeds 1G.s
accel.configureInertialInterrupt(true, 1.0, 10, LIS3DH_X_LOW | LIS3DH_Y_LOW | LIS3DH_Z_LOW | LIS3DH_AOI)
```

### configureFreeFallInterrupt(*state[, threshold][, duration]*) ###

This method configures the inertial interrupt generator to generate interrupts when the device is in free fall, ie. acceleration on all axis approaches 0.

**Note** This method will overwrite any settings configured with [*configureInertialInterrupt()*](#configureinertialinterruptstate-threshold-duration-soptions).

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *threshold* | Float | No | Inertial interrupts threshold in Gs. Default: 0.5 |
| *duration* | Integer | No | Number of samples exceeding threshold required to generate interrupt. Default: 5 |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.configureFreeFallInterrupt(true);
```

### configureClickInterrupt(*state[, clickType][, threshold][, timeLimit][, latency][, window]*) ###

This method configures the click interrupt generator.

#### Parameters ####

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |
| *clickType* | Integer | No | *LIS3DH_SINGLE_CLICK* or *LIS3DH_DOUBLE_CLICK*. Default: *LIS3DH_SINGLE_CLICK* |
| *threshold* | Float | No | Inertial interrupts threshold in Gs. Default: 1.1 |
| *timeLimit* | Float | No | Maximum time in milliseconds the acceleration can spend above the threshold to be considered a click. Default: 5 |
| *latency* | Float | No | Minimum time in milliseconds between the end of one click event and the start of another to be considered a *LIS3DH_DOUBLE_CLICK*. Default: 10 |
| *window* | Float | o | Maximum time in milliseconds between the start of one click event and end of another to be considered a *LIS3DH_DOUBLE_CLICK*. Default: 50 |

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

| Parameter | Type | Required? | Description |
| --- | --- | --- | --- |
| *state* | Boolean | Yes | The interrupt state: `true` to enable, `false` to disable |

#### Return Value ####

Nothing.

#### Example ####

```squirrel
accel.setDataRate(1); // 1Hz
accel.configureDataReadyInterrupt(true);
```

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

```squirrel
local result = accel.getInterruptTable();
if (result.int1) server.log("Interrupt was triggered");
```

## License ##

This library is licensed under the [MIT License](./LICENSE).
