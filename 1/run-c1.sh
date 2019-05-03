#!/bin/bash
set -eo pipefail


echo "** changing directory to c1"
cd ./rootfs/c1/
pwd

echo "** add resolv.conf configuration"
echo "nameserver 1.1.1.1" > ./etc/resolv.conf
echo "** add hostname"

echo  "custom-ubuntu" > ./etc/hostname
sudo mount -o bind /proc ./proc
sudo mount -o bind /dev ./dev

sudo unshare -f \
						-m \
						-p \
						-u \
						bash -c 'sudo chroot ./ /bin/bash -c "hostname custom-ubuntu && export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && bash" '


