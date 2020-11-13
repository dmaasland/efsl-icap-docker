#!/bin/bash

# Some functions
function kill_eset() {
  kill $(</run/eset/efs/startd.pid)
}

function activate_eset() {
  if [ -z "$LICENSE_KEY" ] && [ -z "$LICENSE_FILE" ]
  then
    echo "Please provide either a license key or license file"
    exit 1
  elif [ ! -z "$LICENSE_KEY" ] && [ ! -z "$LICENSE_FILE" ]
  then
    echo "Please only provide one of license key or license file"
    exit 2
  elif [ ! -z "$LICENSE_KEY" ]
  then
    ACT_CMD="-k ${LICENSE_KEY}"
  elif [ ! -z "$LICENSE_KEY" ]
  then
    ACT_CMD="-f ${LICENSE_FILE}"
  fi

  /opt/eset/efs/sbin/lic $ACT_CMD
}

# Trap SIGINT signal to kill ESET daemon
trap kill_eset SIGINT

# Run startd as daemon
/opt/eset/efs/sbin/startd --daemonize
while [ ! -f "/run/eset/efs/startd.pid" ]
do
  sleep 0.5
done

# Activate product
/opt/eset/efs/sbin/lic -s | grep "Status: Activated" || activate_eset

# Update product
/opt/eset/efs/bin/upd

# Import settings
if [ -f "/config/settings.xml" ]
then
  /opt/eset/efs/sbin/cfg --import-xml=/config/settings.xml
fi

# Output log
exec stdbuf -o0 /opt/eset/efs/bin/lslog -f -c