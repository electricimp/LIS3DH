# LIS3DH Examples #

All examples are configured to run on an [impExplorer™ Kit](https://store.electricimp.com/collections/getting-started/products/impexplorer-developer-kit?variant=31118866130). Each example shows simple usage of the accelerometer interrupts. All code runs on the device side only, no agent code is needed.

## Click Interrupt ##

This example configures a double-click interrupt. The device will create a log each time a double-click event is captured.

### Device Code ###

Copy and paste the [code](./simpleClickInterrupt.example.device.nut) into the device coding window in impCentral™.

## Free-fall Interrupt ##

This example shows how to put an imp into deep sleep and configure wakes based on the firing of a timer or a free-fall event condition detection. When the device wakes on a timer it will take and log a reading. If a free-fall event is detected it will log the event. A free-fall event can be triggered by throwing the device up in the air.

### Device Code ###

Copy and paste the [code](./simpleFreefallInterrupt.example.device.nut) into the device coding window in impCentral.

## FIFO Streaming Interrupt ##

This example configures the FIFO buffer in streaming mode and also configures a FIFO watermark interrupt that triggers when the buffer is almost full. When the interrupt is triggered, the readings in the buffer will be checked and logged in a quick burst, preventing a buffer overflow. The stream and interrupt are stopped after a set time, since this example creates many log entries.

### Device Code ###

Copy and paste the [code](./simpleFIFOStream.example.device.nut) into the device coding window in impCentral.

## Motion And Impact Monitoring ##

This example configures the FIFO buffer, a high-pass filter and an inertial interrupt. The high-pass filter and inertial interrupt are configured to trigger an interrupt when movement is detected. When the interrupt is triggered, the FIFO buffer will fill up, storing readings immediately after the motion event was detected. The interrupt handler then looks for the maximum reading captured in the stored readings from the FIFO buffer before clearing and resetting the buffer.

### Device Code ###

Copy and paste the [code](./simpleMotionAndImpactMonitor.example.device.nut) into the device coding window in impCentral.
