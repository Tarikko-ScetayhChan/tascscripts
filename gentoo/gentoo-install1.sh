#!/bin/bash

echo -e "-----------------------------------------------------"
echo -e "|                   \e[1mtascscripts\e[0m                     |"
echo -e "|        Copyright 2024 Tarikko-ScetayhChan         |"
echo -e "|https://github.com/Tarikko-ScetayhChan/tascscripts/|"
echo -e "-----------------------------------------------------"
echo -e "-----------------------------------------------------"
echo -e "|                gentoo-install1.sh                 |"
echo -e "-----------------------------------------------------"
echo -e "This file is part of tascscripts."
echo -e "tascscripts is free software: you can redistribute it"
echo -e "and/or modify it under the terms of the GNU General"
echo -e "Public License as published by the Free Software"
echo -e "Foundation, either version 3 of the License, or (at"
echo -e "your option) any later version."
echo -e "tascscripts is distributed in the hope that it will"
echo -e "be useful, but WITHOUT ANY WARRANTY; without even the"
echo -e "implied warranty of MERCHANTABILITY or FITNESS FOR A"
echo -e "PARTICULAR PURPOSE. See the GNU General Public"
echo -e "License for more details."
echo -e "You should have received a copy of the GNU General"
echo -e "Public License along with tascscripts. If not, see"
echo -e "<https://www.gnu.org/licenses/>."
echo
sleep 5

echo -e "\e[32mInfo: \e[0mThe set environment variables are:"
export nameserver=114.114.114.114
export size_efi_parition=1G
export size_boot_parition=1G
export size_swap_parition=4G
export path_disk=/dev/nvme0n1
export path_efi_parition=/dev/nvme0n1p1
export path_boot_parition=/dev/nvme0n1p2
export path_swap_parition=/dev/nvme0n1p3
export path_root_parition=/dev/nvme0n1p4
export fs_boot_parition=ext4
export fs_root_parition=ext4
export size_swapfile=8G
export address_stage3=https://mirrors.ustc.edu.cn/gentoo/releases/arm64/autobuilds/current-stage3-arm64-openrc/
export site_rsync=rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage
echo -e "    nameserver=${nameserver}"
echo -e "    size_efi_parition=${size_efi_parition}"
echo -e "    size_boot_parition=${size_boot_parition}"
echo -e "    size_swap_parition=${size_swap_parition}"
echo -e "    path_disk=${path_disk}"
echo -e "    path_efi_parition=${path_efi_parition}"
echo -e "    path_boot_parition=${path_boot_parition}"
echo -e "    path_swap_parition=${path_swap_parition}"
echo -e "    path_root_parition=${path_root_parition}"
echo -e "    fs_boot_parition=${fs_boot_parition}"
echo -e "    fs_root_parition=${fs_root_parition}"
echo -e "    size_swapfile=${size_swapfile}"
echo -e "    address_stage3=${address_stage3}"
echo -e "    site_rsync=${site_rsync}"

echo
sleep 5

echo -e "\e[32mInfo: \e[0mRun commands below before turning to ssh:"
echo -e "	passwd"
echo -e " 	/etc/init.d/sshd start"
echo -e " 	ifconfig"
echo
sleep 5

echo -e "\e[33mWarning: \e[0mRead and edit this script before you chmod"
echo -e "+x and run it."
echo
sleep 5

echo -e "\e[33mWarning: \e[0mYou will have 10 seconds to cancel this"
echo -e "script."
sleep 1
echo "10"
sleep 1
echo "9"
sleep 1
echo "8"
sleep 1
echo "7"
sleep 1
echo "6"
sleep 1
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1

echo
echo -e "    \e[32m==> Step 1: \e[0mTo configure the network"
echo
net-setup &&
sleep 1 &&
mv -v /etc/resolv.conf{,.bak};
echo "domain localdomain" > /etc/resolv.conf &&
echo "nameserver ${nameserver}" >> /etc/resolv.conf &&

echo
echo -e "    \e[32m==> Step 2: \e[0mTo partition the disk"
echo
echo -e "g\nn\n1\n\n+${size_efi_parition}\nt\n1\nn\n2\n\n+${size_boot_parition}\nn\n3\n\n+${size_swap_parition}\nn\n4\n\n\nw" > ./gentoo-arm64-install1-fdisk.txt
cat ./gentoo-arm64-install1-fdisk.txt | fdisk ${path_disk}

echo
echo -e "    \e[32m==> Step 3: \e[0mTo create file systems"
echo
mkfs.fat -F 32 ${path_efi_parition} &&
mkfs.${fs_boot_parition} ${path_boot_parition} &&
mkswap ${path_swap_parition} &&
mkfs.${fs_root_parition} ${path_root_parition} &&
fallocate -l ${size_swapfile} /mnt/gentoo/swapfile &&
chmod 600 /mnt/gentoo/swapfile &&
mkswap /mnt/gentoo/swapfile &&

echo
echo -e "    \e[32m==> Step 4: \e[0mTo mount file systems"
echo
mount ${path_root_parition} --mkdir /mnt/gentoo &&
mount ${path_boot_parition} --mkdir /mnt/gentoo/boot &&
mount ${path_efi_parition} --mkdir /mnt/gentoo/boot/efi &&
swapon ${path_swap_parition} &&
swapon /mnt/gentoo/swapfile &&

echo
echo -e "    \e[32m==> Step 5: \e[0mTo download the stage file"
echo
hwclock --systohc;
cd /mnt/gentoo &&
links ${address_stage3} &&
tar xpvf *.tar.xz --xattrs-include='*.*' --numeric-owner &&

echo
echo -e "    \e[32m==> Step 6: \e[0mTo chroot"
echo
mv /mnt/gentoo/etc/portage/make.conf{,.bak};
mkdir -p -v /mnt/gentoo/etc/portage/repos.conf &&
cp -v /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf &&
sed -i "s|rsync:\/\/rsync.gentoo.org\/gentoo-portage|${site_rsync}|g" /mnt/gentoo/etc/portage/repos.conf/gentoo.conf &&
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ &&
echo "export PS1='(chroot) \[\033]0;\u@\h:\w\007\]\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '" > /mnt/gentoo/root/.bashrc;
echo "alias l='ls -ahlF --color'" >> /mnt/gentoo/root/.bashrc;
echo "alias n='neofetch | lolcat'" >> /mnt/gentoo/root/.bashrc;
echo "alias v='nano ~/.bashrc && source ~/.bashrc'" >> /mnt/gentoo/root/.bashrc;
echo "alias emmc='nano /etc/portage/make.conf'" >> /mnt/gentoo/root/.bashrc;
mount --types proc /proc /mnt/gentoo/proc &&
mount --rbind /sys /mnt/gentoo/sys &&
mount --make-rslave /mnt/gentoo/sys &&
mount --rbind /dev /mnt/gentoo/dev &&
mount --make-rslave /mnt/gentoo/dev &&
mount --bind /run /mnt/gentoo/run &&
mount --make-slave /mnt/gentoo/run &&
chroot /mnt/gentoo /bin/bash