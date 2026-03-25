#!/bin/sh
# Copy custom DTS into kernel source tree
cp $(dirname $0)/dts/stm32mp157a-dk1-cloudbuster.dts \
   $LINUX_DIR/arch/arm/boot/dts/st/
