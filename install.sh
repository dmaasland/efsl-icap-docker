#!/bin/bash

# Move to /tmp
pushd /tmp

# Unpack installers
./efs.x86_64.bin -n -y

# Manually move files
/usr/bin/dpkg-deb -xv efs-*.x86_64.deb /

# Create all groups and users
for g in eset-efs-daemons; do
  groupadd -f -r $g
done

for ug in eset-efs-licensed:eset-efs-daemons eset-efs-webd:eset-efs-daemons eset-efs-authd:eset-efs-daemons eset-efs-confd:eset-efs-daemons eset-efs-scand:eset-efs-daemons eset-efs-logd:eset-efs-daemons eset-efs-updated:eset-efs-daemons eset-efs-icapd:eset-efs-daemons; do
  if ! id "${ug%:*}" > /dev/null 2>&1; then
    useradd -d '/opt/eset/efs' -M -N -r -s /sbin/nologin -g "${ug#*:}" "${ug%:*}"
  fi
done

# Change directory permissions
logd_ug='eset-efs-logd:eset-efs-daemons'
chown -R ${logd_ug%:*} '/var/log/eset/efs'
mkdir -p '/var/opt/eset/efs/cache/data/Logs'

chgrp -R 'eset-efs-daemons' '/var/opt/eset/efs/cache' '/var/opt/eset/efs/cache/data' '/var/opt/eset/efs/modules_notice'
for dir in /var/opt/eset/efs/cache /var/opt/eset/efs/cache/data; do
  chmod -R 770 "$dir"
  chmod 1770 "$dir"
done
chmod 1770 '/var/opt/eset/efs/cache/data/Logs'

scand_ug='eset-efs-scand:eset-efs-daemons'
chown -R ${scand_ug%:*} /var/opt/eset/efs/cache

# Extract modules from tar
tar -xf /var/opt/eset/efs/lib/modules_efs.tar -C /var/opt/eset/efs/lib

# Compile modules
/opt/eset/efs/bin/upd --compile-nups

# Set correct user to compiled modules
updated_ug='eset-efs-updated:eset-efs-daemons'
chown -R ${updated_ug} /var/opt/eset/efs/lib

# Change permissions
chmod -R 700 '/var/log/eset/efs'
chmod -R 775 '/var/opt/eset/efs'

chown :'eset-efs-daemons' '/var/opt/eset/efs'

# Move back to starting directory
popd