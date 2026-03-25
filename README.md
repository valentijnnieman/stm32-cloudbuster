# stm32-cloudbuster

BR2_EXTERNAL Buildroot tree for running the Cloudbuster phase vocoder on the STM32MP157A-DK1 discovery board.

## Overview

This repository contains the Buildroot external tree for building a custom Linux image for the STM32MP157A-DK1, configured to run the [Cloudbuster](https://github.com/yourusername/cloudbuster) phase vocoder.

The system consists of:
- Custom Linux image built with Buildroot
- CS42L51 audio codec driver (onboard headphone/line output)
- USB MIDI input support (tested with Roland UM-1)
- Cloudbuster phase vocoder running at boot
- Planned: stm32-controls daemon for physical potentiometer control via ADC

## Hardware

- **Board**: STMicroelectronics STM32MP157A-DK1
- **Audio output**: Onboard 3.5mm headphone jack (CS42L51 codec)
- **MIDI input**: USB MIDI controller (Roland UM-1 or similar)
- **Power**: 5V 3A USB-C supply required

## Repository structure
```
stm32-cloudbuster/
  configs/
    stm32mp157a_dk1_cloudbuster_defconfig  - Buildroot defconfig
  board/
    stmicroelectronics/
      stm32mp157a-dk1/
        overlay/                           - Files overlaid onto rootfs
          etc/
            init.d/
              S41network                   - Network startup script
              S50sshd                      - SSH server startup script
              S60audio                     - Audio mixer configuration
              S70cloudbuster               - Cloudbuster startup script
          root/
            cloudbuster                    - Compiled binary
            samples/                       - Audio samples
            run_cloudbuster.sh             - Restart wrapper script
  package/
    stm32-controls/                        - Planned ADC control daemon
  Makefile                                 - Convenience wrapper
  external.desc                            - BR2_EXTERNAL descriptor
  external.mk                              - BR2_EXTERNAL makefile
  Config.in                                - BR2_EXTERNAL config
```

## Dependencies

- [Buildroot](https://buildroot.org/) — clone to `~/dev/buildroot`
- Buildroot expects this repo at `~/dev/stm32-cloudbuster`

## Quick start
```bash
# Clone Buildroot
git clone https://git.buildroot.net/buildroot ~/dev/buildroot
cd ~/dev/buildroot
git checkout 2024.02

# Clone this repo
git clone <this-repo> ~/dev/stm32-cloudbuster

# Load config and build
cd ~/dev/stm32-cloudbuster
make config
make build

# Flash to SD card
make flash
```

## Make targets

| Target | Description |
|--------|-------------|
| `make config` | Load the defconfig |
| `make build` | Build the image |
| `make menuconfig` | Configure Buildroot packages |
| `make linux-menuconfig` | Configure the Linux kernel |
| `make saveconfig` | Save current config to defconfig |
| `make flash` | Flash image to SD card |

## Network & SSH

The board gets an IP via DHCP on boot. Find it via your router or:
```bash
nmap -sn 192.168.1.0/24
```

SSH in as root with the password configured in Buildroot.

## Audio setup

The CS42L51 codec requires these mixer settings on every boot (handled by S60audio):
```bash
amixer -c 0 cset numid=2 on,on   # unmute PCM playback
amixer -c 0 cset numid=21 0      # set DAC mux to Direct PCM
```

## Kernel configuration highlights

- Preemptible kernel (low latency desktop)
- 1000Hz timer frequency
- High resolution timers
- CS42L51 codec driver
- STM32 SAI interface driver
- Audio graph card machine driver
- USB MIDI support

## Development workflow

Cross-compile cloudbuster on host:
```bash
cd ~/dev/cloudbuster
cmake -B build/arm -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake
cmake --build build/arm
```

Deploy to board without reflashing:
```bash
scp build/arm/cloudbuster root@<board-ip>:/root/
```

## Planned

- stm32-controls daemon: reads potentiometers via ADC and sends MIDI CC messages to cloudbuster
- PREEMPT_RT kernel patch for lower audio latency
