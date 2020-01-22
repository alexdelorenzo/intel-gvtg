#!/usr/bin/env bash

RAM_GB=1.75
trap ctrl_c INT


function ctrl_c() {
	sudo ./intel_gvtg.sh del
}

sudo ./intel_gvtg.sh del
device=$(sudo ./intel_gvtg.sh add "i915-GVTg_V4_8" | tail -1)

# give user permissions
sudo chown -R $USER:$USER "$device"

echo "Using vGPU @ $device"

ionice -c idle nice -n 19 \
  firejail --allusers --ignore=nodbus --whitelist="/home/alex/.local/share/flatpak/exports/share/dconf/profile/user"\
  qemu-system-x86_64 -enable-kvm \
  -machine q35,accel=kvm,kernel_irqchip=on \
  -device intel-iommu -cpu host -m "$RAM_GB"G -smp 2,cores=1,threads=2 \
  --display gtk -device vfio-pci,sysfsdev=$device,rombar=0 \
  -nic user,model=virtio-net-pci -net user,smb=/home/alex \
  -usb -device usb-tablet \
  -boot c -drive file=win10-work.qcow2,media=disk,aio=native,cache.direct=on
#  -cdrom /home/alex/Downloads/virtio-win-0.1.173.iso \
