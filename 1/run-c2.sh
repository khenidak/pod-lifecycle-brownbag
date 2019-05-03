#!/bin/bash
set -eo pipefail


echo "** changing directory to c1"
cd ./rootfs/c2/
pwd

echo "** add resolv.conf configuration"
echo "nameserver 1.1.1.1" > ./etc/resolv.conf
echo "** add hostname"

echo  "nginx" > ./etc/hostname
sudo mount -o bind /proc ./proc
sudo mount -o bind /dev ./dev

sudo unshare -f \
						-m \
						-p \
						-u \
						bash -c 'sudo chroot ./ /bin/bash -c "hostname nginx && export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && bash" '



