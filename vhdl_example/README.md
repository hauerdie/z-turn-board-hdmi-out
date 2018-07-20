# z-turn-board-hdmi-out

VHDL example on generating a HDMI test pattern

There is no oscillator for the PL part of the Zynq 7000 on the board. The processing_system7_0 IP can be used to generate a 74.25Mhz clock which can drive the in_clk.

![Design](https://user-images.githubusercontent.com/668170/43003715-b36f3e6e-8c2d-11e8-8b41-93b22ba6bca5.png)

The Z-Turn board uses a SiI9022A HDMI Transmitter. Unfortunate there is not much information available on the part. ~~The SiI9022A should be configured via i2c, but this is not needed. Even without configuration my TV shows the test pattern. But the output seem to be 1280x720p 85Hz.~~
I was wrong, the sii9022 needs to be configured via i2c. Without the powerup seuqzence, HDMI output will not be turned on.
In the Vivado SDK project, there is a hello world example containing the sii9022 init. This is from the MYIR reference design.

![Example](https://user-images.githubusercontent.com/668170/43003837-1a9f94c6-8c2e-11e8-95d6-0241015f7f46.png)

On the latest DVD from Myir there is now a reference design for HDMI output on the z-turn board which uses Xilinx IP. This can be used with the Webpack lisence without limitations.
I was not able to get HDMI output on Linux till now, just crap on the screen. But the bare metall example works.

http://d.myirtech.com/Z-turn-board/

Therefore I will stop work on this, as it would be to much work to get it usefull.
