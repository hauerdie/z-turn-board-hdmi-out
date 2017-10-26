# z-turn-board-hdmi-out

VHDL example on generating a HDMI test pattern

There is no oscillator for the PL part of the Zynq 7000 on the board. The processing_system7_0 IP can be used to generate a 74.25Mhz clock which can drive the in_clk.

The Z-Turn board uses a SiI9022A HDMI Transmitter. Unfortunate there is not much information available on the part. The SiI9022A should be configured via i2c, but this is not needed. Even without configuration my TV shows the test pattern. But the output seem to be 1280x720p 85Hz.
