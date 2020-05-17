#!/bin/bash
set -e -x

# Scripts
chmod a+x /install/fs/usr/bin/*

# Dependencies
apt-get update
apt-get install -y curl cron fuse unionfs-fuse ca-certificates openssl rsync
update-ca-certificates

# Rclone
RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-amd64.deb"
curl "$RCLONE_URL" -L -o ./rclone.deb
dpkg -i ./rclone.deb
rm ./rclone.deb

# Plexdrive
PLEXDRIVE_RELEASES_URL="https://api.github.com/repos/plexdrive/plexdrive/releases/latest"
PLEXDRIVE_LATEST_RELEASE=`curl -s "$PLEXDRIVE_RELEASES_URL" | grep "browser_download_url.*plexdrive-linux-amd64\"" | cut -d : -f 2,3 | tr -d \" | tr -d '[:space:]'`
curl "$PLEXDRIVE_LATEST_RELEASE" -L -o ./plexdrive
chmod a+x ./plexdrive
mv ./plexdrive /usr/bin/plexdrive

# S6
S6_RELEASES_URL="https://api.github.com/repos/just-containers/s6-overlay/releases/latest"
S6_LATEST_RELEASE=`curl -s "$S6_RELEASES_URL" | grep "browser_download_url.*s6-overlay-amd64.tar.gz\"" | cut -d : -f 2,3 | tr -d \" | tr -d '[:space:]'`
curl "$S6_LATEST_RELEASE" -L -o ./s6.tar.gz
tar xfz ./s6.tar.gz -C /install/fs/
rm ./s6.tar.gz

# Fuse
sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# Directories
mkdir /config
mkdir -p /data/db
mkdir /log
chmod -R 777 /config /data /log

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
