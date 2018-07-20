##### Example on how to get video out (1080p60) on the z-Turn Board in Linux with Xilinx IP using the simple framebuffer driver.

The new reference display driver from MIYR uses just Xilinx IP. Via Video Timing Controller, Video DMA and AXI4-Stream to Video Out display data is streamed to HDMI.

To get this going, we just need to start the Video Timing Controler and Video DMA. This can be done in the FSBL, after the bitstream is loaded into the FPGA (it only works if we laod the bitstream from the FSBL and not from u-Boot).

We need to change the Design, because of an error, change the FSBL to get VTC and VDMA going and create a new BOOT.bin. Unfortunate we also need to compile a new u-boot and new kernel. (I was not able to get this going with the u-boot from the DVD and I was also not able to get the simple framebuffer going in Linux 3.15)

##### Download the Xilinx Display Release Project from MYIR.

http://d.myirtech.com/Xilinx-Update-Temp/xilinx-display-release/z-turn/

##### Open the Project in Vivado.
There is an error in the desing. a8b8g8r8 from the framebuffer needs to be convertet in the stream to rgb with an axis subset converter. Instead of the alpha channel, the blue channel is dumped. The correction is easy.

In Block Design, open the axis_subset_converter_0 and change 'TDATA Remap String' to tdata[23:16],tdata[15:8],tdata[7:0]

Generate Bitstream and export to SDK (don't forget to include bitstream).

##### Create a new FSBL Project in the SDK.

Add/exchange the files from the github fsbl directory to the scr directory in the fsbl project and compile.

	Description
	ssi9022_init() initializes the ssi9022 chip with the right config for 1080p60.
	display_init() starts the vtc and vdma with 1080p60 reading video data from memory at 0x3F000000.

both functions need to be called after the bitstream has been loaded. This is done in fsbl_hooks.c
  
##### Now we need a new u-boot, you can build it from source.
https://github.com/Xilinx/u-boot-xlnx

Defconfig is in my u-boot directory or just use the u-boot binary from there.

Create Boot Image (from Xilinx menu) and add fsbl.elf, hdmi_out_wrapper.bit and u-boot.elf.

If you now try to boot with this boot.bin, the display should turn on right after the FPGA is initialized.
But you will just see uninitialized ram on the display.

##### Compile a new kernel with simple framebuffer driver.

There is a Defconfig for linux-xlnx in the kernel folder (GPIO and Leds not working)

For the driver to be loaded by the kernel we need to add the following to the device tree in the chosen section after the bootargs or linux,stdout-path...

```
      #address-cells = <0x1>;
      #size-cells = <0x1>;
      ranges;
      framebuffer0: framebuffer@3F000000 {
              compatible = "simple-framebuffer";
              reg = <0x3F000000 (1920*1080*4)>;
              width = <1920>;
              height = <1080>;
              stride = <(1920*4)>;
              format = "a8r8g8b8";
              status = "okay";
      };
```
This tells Linux the format and adress of the RAM for the framebuffer.

Now we need to reserve some RAM for the framebuffer by changing the memory section int the device tree (10MB are enough).
Change the reg in memory to 0x3F000000
```
       memory {
                device_type = "memory";
                reg = <0x0 0x3F000000>;
        };
```

You can find my kernel (4.14.0-xilinx) in the boot folder (boot.bin, uImage and devicetree.dtb).
It should work with xillinux-2 but I use it with the latest Raspbean Stretch (Lite and Desktop).
  
