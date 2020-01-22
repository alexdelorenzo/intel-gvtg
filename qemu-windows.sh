#!/usr/bin/env bash

RAM_GB=1.75
VGPU="i915-GVTg_V4_8"
DISK="win10-work.qcow2"

trap ctrl_c INT

function ctrl_c() {
	sudo ./intel_gvtg.sh del
}

# delete old vgpus and add new one
sudo ./intel_gvtg.sh del
device=$(sudo ./intel_gvtg.sh add "$VGPU" | tail -1)

# give access to vgpu to user
sudo chown -R $USER:$USER "$device"

echo "Using vGPU @ $device"

# launch qemu under firejail
# using ionice and nice to set low priorities

ionice -c idle nice -n 19 \
  firejail \
    --allusers --ignore=nodbus \
    --whitelist=$(pwd) --whitelist="/var/lib/flatpak" \
  qemu-system-x86_64 --display gtk -enable-kvm \
    -machine q35,accel=kvm,kernel_irqchip=on \
    -device intel-iommu -cpu host -m "$RAM_GB"G -smp 2,cores=1,threads=2 \
    -device vfio-pci,sysfsdev=$device,rombar=0 \
    -nic user,model=virtio-net-pci -net user,smb=/home/alex \
    -usb -device usb-tablet \
    -boot c -drive file="$DISK",media=disk,aio=native,cache.direct=on
#   -cdrom /home/alex/Downloads/virtio-win-0.1.173.iso \
