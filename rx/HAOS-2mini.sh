#!/bin/bash
# Setup HAOS VM on 2mini

# Download HAOS image for VM
wget https://github.com/home-assistant/operating-system/releases/download/13.2/haos_ova-13.2.qcow2.xz
xz -d haos_ova-13.2.qcow2.xz

# Create VM with QEMU
qemu-img create -f qcow2 haos-vm.qcow2 32G
qemu-system-aarch64 \
  -M virt \
  -cpu host \
  -smp 2 \
  -m 4096 \
  -drive file=haos-vm.qcow2,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::8123-:8123 \
  -device virtio-net-pci,netdev=net0 \
  -nographic

# Or use UTM for GUI management
