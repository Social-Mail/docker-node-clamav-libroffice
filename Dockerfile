FROM node:18-alpine
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