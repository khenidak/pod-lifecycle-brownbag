#!/bin/bash

set -eo pipefail

c1_dir="./rootfs/c1"
c2_dir="./rootfs/c2"
working_dir_c1="./tmp/c1"
working_dir_c2="./tmp/c2"

ns_name="super_ns"

## this is written to be re-runnable so 
## clean here

echo "cleaning.."
sudo ip netns pids ${ns_name} | xargs kill >> /dev/null 2>&1  || true
sudo ip netns exec ${ns_name} ip link del v_c >> /dev/null 2>&1 || true
sudo ip netns del ${ns_name}  >> /dev/null 2>&1 || true

sudo ip link del c  >> /dev/null 2>&1 || true
sudo ip link set lifecycle down  >> /dev/null 2>&1 || true
sudo brctl delbr lifecycle >> /dev/null 2>&1 || true

sudo umount ${c1_dir}/proc >> /dev/null 2>&1|| true

sudo rm -rf ${c1_dir}
sudo rm -rf ${c2_dir}

sudo rm -rf ${working_dir_c1}
sudo rm -rf ${working_dir_c2}

## start here
echo "** create the directories"
mkdir -p ${c1_dir}
mkdir -p ${c2_dir}
mkdir -p ${working_dir_c1}
mkdir -p ${working_dir_c2}

## download-frozen-image-v2.sh is part of moby project
## thank you moby folks
echo "*** downloading images"
echo "*** network utils, because reasons!"
./download-frozen-image-v2.sh ${working_dir_c1}/ amouat/network-utils:latest

echo "*** socat, because other reasons"
./download-frozen-image-v2.sh ${working_dir_c2}/ nginx:latest



# extract, output muted 
# so we don't confuse folks
# with /proc and what not

echo "*** extracting nginx image layers"
cat ${working_dir_c1}/manifest.json | \
		jq -r '.[0].Layers[]' | \
		tac | \
		xargs -I {} tar -xf ${working_dir_c1}/{} -C ${c1_dir}  >/dev/null 2>&1 || true 

#echo "*** adding our config thing"
#cp -v ./run-c1.sh ${c1_dir}/bin/

echo "files at ${c1_dir}"
ls -lah ${c1_dir}

sudo chown -R root:root ${c1_dir} 

echo "*** extracting nginx image layers"
cat ${working_dir_c2}/manifest.json | \
		jq -r '.[0].Layers[]' | \
		tac | \
		xargs -I {} tar -xf ${working_dir_c2}/{} -C ${c2_dir}  >/dev/null 2>&1 || true 

#echo "*** adding our config thing"
#cp -v ./setup-c2.sh ${c2_dir}/bin/

echo "*** files at ${c2_dir}"
ls -lah ${c2_dir}
sudo chown -R root:root ${c2_dir}

