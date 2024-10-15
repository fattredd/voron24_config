# Voron 2.4 config

Herein lies the config for my self-built Voron 2.4.

Below is extra steps for setup.

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
./scripts/calibrate_shaper.py /tmp/calibration_data_x_*.csv -o ~/printer_data/config/shaper_calibrate_x.png
./scripts/calibrate_shaper.py /tmp/calibration_data_y_*.csv -o ~/printer_data/config/shaper_calibrate_y.png
```
