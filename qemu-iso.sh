#!/usr/bin/env bash

iso="${1:-no_iso_specified.iso}"

trap ctrl_c INT

function ctrl_c() {
	sudo ./intel_gvtg.sh del
}

sudo ./intel_gvtg.sh del
device=$(sudo ./intel_gvtg.sh add | tail -1)

printf "Using vGPU @ $device\n"

sudo ionice -c idle nice -n 19 \
  /usr/bin/qemu-system-x86_64 -enable-kvm \
  -machine q35,accel=kvm,kernel_irqchip=on \
  -device intel-iommu \
  --display gtk \
  -usb -device usb-tablet \
  -cdrom "$iso" -boot c
#  -device vfio-pci,sysfsdev=$device,rombar=0
#  -nic user,model=virtio-net-pci -net user,smb=/home/alex \
#  -cpu host -m 1.75G -smp 2,cores=1,threads=2 \

ctrl_c
 #-boot d -drive file="$iso",media=disk,aio=native,cache.direct=on \
