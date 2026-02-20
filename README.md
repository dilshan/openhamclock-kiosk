
# OpenHamClock Kiosk

A customized, Armbian-based Linux system designed to launch [*OpenHamClock*](https://github.com/accius/openhamclock) in a dedicated kiosk mode on the [Banana Pi Zero M4 Zero](https://docs.banana-pi.org/en/BPI-M4_Zero/BananaPi_BPI-M4_Zero).

This image is built on the X Window System using the Openbox window manager and Chromium. It is engineered for a "plug-and-play" experience—once flashed, it requires no user interaction, keyboard, or mouse to function. WiFi and system localization are pre-configured at build time for seamless deployment.


## Prerequisites

For a smooth build process, we recommend using a Linux environment (the prototype was developed on *Ubuntu 24.04 LTS*).


### Build System Requirements

| Component | Minimum Requirement |
| :--- | :--- |
| **RAM** | 8GB or more |
| **Storage** | ~50GB free disk space |
| **Architecture** | x86-64, ARM64, or RISC-V |
| **Privileges** | Superuser (sudo) access |


## Building the Operating System

### 1. Clone the Repository

```bash
git  clone  https://github.com/dilshan/openhamclock-kiosk.git
cd  openhamclock-kiosk
```

### 2. Configuration

Before building, you must define your network and regional settings in `userpatches/customize-image.sh`

*  **WiFi SSID:** Search for `[wifi]` and update the `ssid` field.
*  **WiFi Password:** Search for `[wifi-security]` and update the `psk` field.
*  **Timezone:** Search for `/etc/localtime` and update the symlink to your [IANA Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
Example:  `ln -sf /usr/share/zoneinfo/Asia/Colombo /etc/localtime`

*  **Hostname & Root Password (*optional*):** You can modify these in the script. To generate a secure password hash, use:
	```bash
	openssl  passwd  -6  "YOUR_NEW_PASSWORD"
	```

* **Further Customizations**: For any additional system tweaks, please consult the [Armbian documentation](https://docs.armbian.com/).

### 3. Start the Build Process

Execute the compile script:
```bash
./compile.sh  bpim4zero-openhamclock
```

> **IMPORTANT**
> During the process, the *Linux kernel menuconfig* interface will appear. We highly recommend keeping all settings at their default values. An active internet connection is required throughout the build.

## Flashing the Image

### 4. Locate the Image

Once the build finishes, navigate to the output directory:
```bash
cd  output/images
```

### 5. Write to SD Card

Insert a 4GB or 8GB SD card into your build PC. Identify its device path (e.g., `/dev/sdX`) and run the following command.

> **WARNING**
> This will permanently delete all data on the SD card. Ensure `of=/dev/sdX` points to the correct drive.

```bash
sudo  dd  if=Armbian-unofficial_26.02.0-trunk_Bananapim4zero_trixie_current_6.12.73_minimal.img  of=/dev/sdX  bs=1M  status=progress  conv=fsync
```

### 6. Boot

Unmount the SD card, insert it into your Banana Pi Zero M4 Zero, and power it on. The system will automatically boot into OpenHamClock.