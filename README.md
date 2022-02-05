
Docker RTL MUS Server
======

# Purpose

This Docker container will create a RTL Multi-User Service allowing you to use your RTL dongle(s) with more than one application at a time.

To do this, we wrap [rtl_tcp](https://osmocom.org/projects/rtl-sdr/wiki/Rtl-sdr) and [rtl_mus](https://github.com/ha7ilm/rtl_mus) in a lightweight [Alpine Linux](https://alpinelinux.org/) docker container and expose the service on the default rtl_tcp port `1234`.

You then simply connect to this where you would connect to any other RTL_TCP service. It can be run multiple times for more than one RTL dongle too.

This container *should* work on *most* Linux operating systems including Raspberry Pi's.

# Warnings

### Disable Kernel modules

To use this script you **must** have blacklisted the RTL Kernel modules **on the Docker host**.

To do this, run the following:

```bash
sudo tee -a "blacklist rtl8xxxu
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830" > /etc/modprobe.d/blacklist-rtl.conf
```

After doing the above, you must *reboot* your Docker host for these to take effect.

### Using multiple applications at once

When using multiple applications at once, changing the receiver frequency will **not** inform the other applications.

They will get the new IQ data for the new frequency but they will still display the old frequency.

Example:

* Application A connects and tunes the receiver to 100 MHz
* Application B connects and tunes the receiver to 200 MHz
* Application A still displays 100 MHz but is receiving IQ data for 200 MHz

**This is a limitation of RTL_TCP** - Keep this in mind when using this container. *It's not my fault.*

# Building the container image

This guide expects that you...

* Have basic Docker and Linux knowledge
* Have Docker running (you get no errors when you run `sudo docker ps -a`) 
* You know the device indexes of your RTL dongle(s) if using more than one

To build the Docker container, run the following command:

```bash
sudo docker build --label rtl_mus -t "jasongaunt/rtl_mus:1.0"
```

This won't take long and will then provide you with a local Docker image you can run.

# Running the container(s)

### One dongle with default configuration

If you only have one RTL dongle and want to get this running immediately, run the following command:

```bash
sudo docker run -d --name rtl_mus_device_0 --restart=always --device /dev/bus/usb -p 1234:7373 jasongaunt/rtl_mus:1.0
```

That will create a basic RTL MUS server with the following defaults...

* Device Index: 0
* Sample Rate: 2400000 (2.4 MS/s)
* Device Gain: 0 (0 = Automatic Gain)
* Device PPM: 0
* Device Bias Tee: Off
* Device buffers: 15
* Device linked list buffers: 500

You should be able to connect straight away on port 1234.

### More than one dongle and / or advanced configuration

If you need to tweak the RTL settings, or run this service multiple times, a more advanced command is required:

```bash
sudo docker run -d \
  --name rtl_mus_device_0 \
  --restart=always \
  --device /dev/bus/usb \
  -p NEWPORT:7373\
  -e 'DEVICE_INDEX=DEVICE_ID' \
  -e 'DEVICE_SAMPLE_RATE=2400000' \
  -e 'DEVICE_PPM=0' \
  -e 'DEVICE_GAIN=0' \
  -e 'DEVICE_BIAS_TEE_ENABLE=0' \
  -e 'DEVICE_BUFFERS=15' \
  -e 'DEVICE_LINKED_LIST_BUFFERS=500' \
  jasongaunt/rtl_mus:1.0
```

You will need to run this for every device and **CHANGE THE FOLLOWING**:

* Change `rtl_mus_device_0` to suit the device name
* Change `NEWPORT` for every device, for example:
	* `1234:7373` for device 0
	* `1235:7373` for device 1
* Change `DEVICE_INDEX=DEVICE_ID` for every device, for example:
	* `DEVICE_INDEX=0` for device 0
	* `DEVICE_INDEX=1` for device 1

You do **not** need to specify every `-e` option, they will inherit the defaults in the previous section.

If however you have more than one device, you *MUST* at least specify the `  -e 'DEVICE_INDEX=DEVICE_ID' \` for each device as described above.

Here is an example on how to run two dongles with their default configurations:

```bash
sudo docker run -d \
  --name rtl_mus_device_0 \
  --restart=always \
  --device /dev/bus/usb \
  -p 1234:7373 \
  -e 'DEVICE_INDEX=0' \
  jasongaunt/rtl_mus:1.0

sudo docker run -d \
  --name rtl_mus_device_1 \
  --restart=always \
  --device /dev/bus/usb \
  -p 1235:7373 \
  -e 'DEVICE_INDEX=1' \
  jasongaunt/rtl_mus:1.0
```

You can then connect to the first dongle on port 1234 and the second dongle on port 1235.

# Authors
Jason Gaunt (this Docker wrapper repository)
András Retzler ha7ilm@sdr.hu (RTL MUS service)