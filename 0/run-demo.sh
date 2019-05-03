#!/bin/bash
set -eo pipefail

new_root="./rootfs"

## start here ##
# this to make the demo re-runable
echo "** deleteing old root, if exists"
if [[ -d "${new_root}" ]]; then
	sudo umount ${new_root}/proc || true
	rm -rf "${new_root}"
fi

echo "** creating new root"
mkdir -p ${new_root}/{bin,lib64,lib}

echo "** copy binaries into new root"
cp -v /bin/{bash,ls,pwd} ${new_root}/bin
echo "** copying the entire /lib and /lib64 (no creative ldd here)"
cp -a /lib ${new_root}
cp -a /lib64 ${new_root}


### Preping the chroot env
## procfs
mkdir ${new_root}/proc

echo "** mount bind proc, to all process to see itself"
sudo mount -o bind /proc ${new_root}/proc

echo "ls -ld /proc/<PID>/root inside and outside the chroot env"
echo "chrooting into ${new_root} with bash"
# sys calls
# getcwd()
# chroot()
# chdir()
# execve()
sudo chroot "${new_root}/" /bin/bash

