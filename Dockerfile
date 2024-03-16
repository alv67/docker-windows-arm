FROM scratch
COPY --from=qemux/qemu-arm:1.06 / /

ARG DEBCONF_NOWARNINGS "yes"
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN "true"

# We need wimtools from debian unstable, but everything else (above) should be stable only
RUN echo "deb http://deb.debian.org/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
    && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default \
    && apt-get update && apt-get install -y -t unstable wimtools \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/apt/sources.list.d/debian-unstable.list 

RUN apt-get update \
    && apt-get --no-install-recommends -y install \
    curl \
    7zip \
    wsdd \
    samba \
    dos2unix \
    cabextract \
    genisoimage \
    libxml2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY ./assets /run/assets

ADD https://raw.githubusercontent.com/christgau/wsdd/master/src/wsdd.py /usr/sbin/wsdd
ADD https://github.com/qemus/virtiso-arm/releases/download/v0.1.248/virtio-win-0.1.248.iso /run/drivers.iso

RUN chmod +x /run/*.sh && chmod +x /usr/sbin/wsdd

EXPOSE 8006 3389
VOLUME /storage

ENV RAM_SIZE "6G"
ENV CPU_CORES "4"
ENV DISK_SIZE "64G"
ENV VERSION "win11"
ENV KVM "N"

ARG VERSION_ARG "0.0"
RUN echo "$VERSION_ARG" > /run/version

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
