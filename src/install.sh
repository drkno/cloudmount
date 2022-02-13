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
S6_VERSION_NUM=`curl -s "$S6_RELEASES_URL" | grep '"tag_name": "' | sed -E 's/.* "v?([^"]+)".*/\1/'`
curl "https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION_NUM/s6-overlay-noarch-$S6_VERSION_NUM.tar.xz" -L -o ./s6-overlay.tar.xz
curl "https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION_NUM/s6-overlay-x86_64-$S6_VERSION_NUM.tar.xz" -L -o ./s6-overlay-bin.tar.xz
curl "https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION_NUM/s6-overlay-symlinks-noarch-$S6_VERSION_NUM.tar.xz" -L -o ./s6-overlay-symlinks.tar.xz
tar -C /install/fs -Jxpf ./s6-overlay.tar.xz
tar -C /install/fs -Jxpf ./s6-overlay-bin.tar.xz
tar -C /install/fs -Jxpf ./s6-overlay-symlinks.tar.xz
rm -rf ./s6*.tar.xz
echo '/command:/usr/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin' > /install/fs/etc/s6-overlay/config/global_path

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
