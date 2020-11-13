# ESET File Security for Linux ICAP scanning container
This container runs ESET File Security for Linux in a container, and exposes ICAP via port 1344.

## Building
To build this container, first download the EFSL installer:
```bash
wget https://download.eset.com/com/eset/apps/business/efs/linux/latest/efs.x86_64.bin
```

Then build the container as you normally would.

## Running
The container requires either a license key or a path to an offline license file passed as environment variables. These are mutually exclusive. Either use:

- **`LICENSE_KEY`**: A license key
- **`LICENSE_FILE`**: Path to an offlince license file

Example:
```bash
docker run -p 1344:1344 -e LICENSE_KEY=1234-ABCD-5678-EFGH-90IJ efsl-icap
```

**NOTE:** There will be an error about being unable to find the **`eset_rtp`** module. This is a kernel module used for on-access scanning. For obvious reasons this is not included in this container.

## Volumes
This container uses two volumes:

- **`/config`**: Contains the **`settings.xml`** file
- **`/var/opt/eset`**: Contains the ESET modules, license information, current settings, cache, etc.

## Settings
The **`settings.xml`** file contains the initial settings for the product. Please note that all ports in this file are in hexadecimal notation. The easiest way to add settings is to install the product in a VM, configure it and export the settings.

## Privileges
The container runs the watchdog application **`startd`** as root. This will spawn several child processes. Some with their own dedicated user, some as `root`. Unfortunately, there is nothing I can do about this currently.
