#!/usr/bin/env bash

### setup any local NVME drives as raid0 array

local_drives=($(ls /dev/nvme[1-9]n1 || exit 0))
sudo mdadm --create /dev/md127 --force --level=stripe --raid-devices=${#local_drives[@]} ${local_drives[@]}
sudo mkfs.xfs /dev/md127
echo "/dev/md127 /mnt xfs defaults,noatime 1 1" | sudo tee -a /etc/fstab
sudo mount /mnt

### setup kubelet to use array

sudo mkdir /mnt/kubelet
sudo mv /var/lib/kubelet/kubeconfig /tmp/kubeconfig
echo "/mnt/kubelet /var/lib/kubelet none bind" | sudo tee -a /etc/fstab
sudo mount /var/lib/kubelet
sudo mv /tmp/kubeconfig /var/lib/kubelet/kubeconfig
