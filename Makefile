BUILDROOT := /home/valentijn/dev/buildroot
BR2_EXTERNAL := $(shell pwd)
DEFCONFIG := stm32mp157a_dk1_cloudbuster_defconfig

# Pass all other arguments to Buildroot
BR2_MAKE := $(MAKE) -C $(BUILDROOT) BR2_EXTERNAL=$(BR2_EXTERNAL)

.PHONY: all config menuconfig linux-menuconfig saveconfig flash help

all:
	$(BR2_MAKE)

config:
	$(BR2_MAKE) $(DEFCONFIG)

menuconfig:
	$(BR2_MAKE) menuconfig

linux-menuconfig:
	$(BR2_MAKE) linux-menuconfig

linux-dirclean:
	$(BR2_MAKE) linux-dirclean

linux-rebuild:
	$(BR2_MAKE) linux-rebuild

uboot-dirclean:
	$(BR2_MAKE) uboot-dirclean

uboot-rebuild:
	$(BR2_MAKE) uboot-rebuild

saveconfig:
	$(BR2_MAKE) savedefconfig BR2_DEFCONFIG=$(BR2_EXTERNAL)/configs/$(DEFCONFIG)

build:
	$(BR2_MAKE) -j$(shell nproc)

flash:
	@echo "Flashing to SD card..."
	@read -p "Enter SD card device (e.g. /dev/sdb): " DEV; \
	sudo dd if=$(BUILDROOT)/output/images/sdcard.img of=$$DEV bs=4M status=progress; \
	sync

help:
	@echo "Available targets:"
	@echo "  config            - Load defconfig"
	@echo "  build             - Build image"
	@echo "  menuconfig        - Buildroot menuconfig"
	@echo "  linux-menuconfig  - Kernel menuconfig"
	@echo "  saveconfig        - Save current config"
	@echo "  flash             - Flash image to SD card"
