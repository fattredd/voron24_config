# Voron 2.4 config

Herein lies the config for my self-built Voron 2.4.

Below is extra steps for setup.

## Debugging

[Analyze klippy.log](https://doctor-klipper.clmntw.fr/)

## PID Tuning

Be sure to turn on the filter fan before bed tuning:
```
START_FILTER SPEED=1
PID_CALIBRATE HEATER=heater_bed TARGET=100
STOP_FILTER

PID_CALIBRATE HEATER=extruder TARGET=255
```

## Set vars during runtime

```
# Temporarily change a variable (reset on restart)
SET_GCODE_VARIABLE MACRO=_USER_VARIABLES_OTHER VARIABLE=force_homing_in_start_print VALUE=False

# Save a var locally
SAVE_VARIABLE VARIABLE=temperature_target VALUE={TARGET_TEMP}
```

## Filter monitoring

Check the status of the filter:
`QUERY_FILTER EXTENDED=True`

Reset the filter:
`FILTER_RESET`

## Auto-Z calibration (removed)

https://github.com/protoloft/klipper_z_calibration/wiki/How-To-Use-It

Run `CALIBRATE_Z` to find the actual Z offset.

To figure out the switch_offset, do the paper level test, then run;
`CALCULATE_SWITCH_OFFSET`

## Quad gantry leveling

https://docs.vorondesign.com/build/startup/#quad-gantry-level-v2

`PROBE_ACCURACY`
`QUAD_GANTRY_LEVEL`

## Input Shaping Setup:

https://www.klipper3d.org/RPi_microcontroller.html
https://www.klipper3d.org/Measuring_Resonances.html#measuring-the-resonances

Make sure the Linux SPI driver is enabled by running `sudo raspi-config`and
enabling SPI under the "Interfacing options" menu.

```
cd ~/klipper/
sudo cp ./scripts/klipper-mcu.service /etc/systemd/system/
sudo systemctl enable klipper-mcu.service
```

```
cd ~/klipper/
make menuconfig
```

In the menu, set "Microcontroller Architecture" to "Linux process," then save and exit.

To build and install the new micro-controller code, run:
```
sudo service klipper stop
make flash
sudo service klipper start
```

Once things are setup, use the following macros:
```
MEASURE_AXES_NOISE # Reports the noise level of the adxl sensor
ACCELEROMETER_QUERY # Takes a sensor reading. Useful to ensure the sensor is alive.

SHAPER_CALIBRATE # Calibrate X & Y

TEST_RESONANCES AXIS=X # Calibrate just X
TEST_RESONANCES AXIS=Y # Calibrate just Y
```

To get a graph, run:
```
./data/shaper_parse.sh
```

## tmc setter autotune

https://github.com/andrewmcgr/klipper_tmc_autotune

`AUTOTUNE_TMC STEPPER=<name> [PARAMETER=<value>]`

e.g.:
`AUTOTUNE_TMC STEPPER=stepper_x tuning_goal=silent`

## Maintanence

https://3dcoded.github.io/KlipperMaintenance/gcodes/

- `MAINTAIN_STATUS` Shows the current maintenance status
- `CHECK_MAINTENANCE NAME=airfilter` Shows a specific maintenance item
- `UPDATE_MAINTENANCE NAME=airfilter` Sets the last maintenance time to now

# Cartographer

[Config](https://docs.cartographer3d.com/cartographer-probe/installation-and-setup/installation/calibration)

# Canbus

~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0

https://canbus.esoterical.online/
