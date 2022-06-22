#!/bin/bash
# Script to add nbd server config on host machine
# Input $1 Path to image files
#---------------------------
echo "Prerequisites check.."
command -v simg2img >/dev/null 2>&1 || { echo >&2 "simg2img is not installed. sudo apt-get -y install simg2img."; exit 1; }
command -v nbd-server >/dev/null 2>&1 || { echo >&2 "nbd-server is not installed. sudo apt-get install nbd-server"; exit 1; }
echo "Prereq check complete."

while getopts p: flag
do
    case "${flag}" in
        p) imagepath=${OPTARG};;
    esac
done
echo "Image Path: $imagepath";

## convert sparse system.img from path to unsparse system.img
sudo mkdir tmp && cd tmp
sudo cp $imagepath/system.img .
sudo simg2img system.img system_raw.img
systemdevloop=$(losetup -f)
sudo losetup $systemdevloop system_raw.img
#Test dev/loop partition by mounting
#sudo mount -t ext4 </dev/loop0 .mount point

# Create nbd-server config
sudo cat << EOF > /etc/nbd-server/config
[generic]
allowlist = true
[rootfs]
exportname = $systemdevloop
EOF

sudo nbd-server