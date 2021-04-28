FROM ubuntu:20.04

# Set debian frontend
ARG DEBIAN_FRONTEND=noninteractive

# Copy files
RUN mkdir /config
ADD https://download.eset.com/com/eset/apps/business/efs/linux/latest/efs.x86_64.bin /tmp/efs.x86_64.bin
COPY settings.xml /config/settings.xml
COPY entrypoint.sh /entrypoint.sh
COPY install.sh /install.sh

# Set permissions
RUN chmod +x \ 
  /entrypoint.sh \
  /install.sh \
  /tmp/efs.x86_64.bin \
  && chmod 600 \
  /config/settings.xml

# Install needed packages
RUN apt-get update && apt-get install -y \
  openssl \
  cron \
  libelf-dev \
  && rm -rf /var/lib/apt/lists/*

# Run install
RUN /install.sh \
  && rm -f /tmp/efs*

# Volume
VOLUME [ "/config", "/var/opt/eset" ]

# Ports
EXPOSE 1344/tcp

# Signal
STOPSIGNAL SIGINT

# Use on-demand scan as healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
  CMD /opt/eset/efs/sbin/lic -s | grep "Status: Activated" \
    && /opt/eset/efs/bin/odscan -s --profile="@Smart scan" --readonly /etc/passwd

# Run entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]