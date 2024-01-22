FROM node:20.10-alpine
RUN apk add --no-cache tini
RUN apk add 7zip clamav && \
    sed -i 's/^#Foreground .*$/Foreground yes/g' /etc/clamav/clamd.conf && \
    echo "TCPAddr 0.0.0.0" >> /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf && \
    freshclam && \
    chown clamav:clamav /var/lib/clamav/*.cvd && \ 
    mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

ARG APP_ROOT=/opt/app-root/src
ENV NO_UPDATE_NOTIFIER=true \
    PATH="/usr/lib/libreoffice/program:${PATH}" \
    PYTHONUNBUFFERED=1
WORKDIR ${APP_ROOT}

# Install LibreOffice & Common Fonts
RUN apk --no-cache add bash libreoffice util-linux \
    font-droid-nonlatin font-droid ttf-dejavu ttf-freefont ttf-liberation && \
    rm -rf /var/cache/apk/*

# Install Microsoft Core Fonts
RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f && \
    rm -rf /var/cache/apk/*