#!/bin/bash
set -e -x

# Scripts
chmod a+x /install/fs/usr/bin/*
chmod a+x /install/fs/etc/cont-*.d/*
chmod a+x /install/fs/etc/services.d/*/run

# Dependencies
apt-get update
apt-get install -y curl cron fuse unionfs-fuse ca-certificates openssl rsync python3 python3-pip git
update-ca-certificates

# Rclone
RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-amd64.deb"
curl "$RCLONE_URL" -L -o ./rclone.deb
dpkg -i ./rclone.deb
rm ./rclone.deb

# S6
S6_RELEASES_URL="https://api.github.com/repos/just-containers/s6-overlay/releases/latest"
S6_LATEST_RELEASE=`curl -s "$S6_RELEASES_URL" | grep -E "browser_download_url.*s6-overlay-x86_64[a-zA-Z0-9\\.\\-]+.tar.xz\"" | cut -d : -f 2,3 | tr -d \" | tr -d '[:space:]'`
curl "$S6_LATEST_RELEASE" -L -o ./s6.tar.xz
tar -xf ./s6.tar.xz -C /install/fs/
rm /install/fs/usr/bin/execlineb
rm ./s6.tar.xz

# Fuse
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# CloudPlow
python3 -m pip install --no-cache-dir --upgrade -r /install/fs/opt/cloudplow/requirements.txt
rm -rf /install/fs/opt/cloudplow/.git

# Directories
mkdir /config
chmod -R 777 /config

# User and Group
groupmod -g 1000 users
useradd -u 911 -U -d / -s /bin/false abc
usermod -G users abc

# Move files
rsync --remove-source-files -avIK /install/fs/ /

# Cleanup
rm -r /install
apt-get clean autoclean
apt-get autoremove -y
rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/
