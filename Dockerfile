FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    dbus \
    dbus-x11 \
    nginx-light \
    procps \
    fonts-noto-cjk \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

RUN mkdir -p /data/chrome-profile

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV WIDTH=1920
ENV HEIGHT=1080
ENV VNC_PASSWORD=
ENV CDP_TOKEN=

EXPOSE 9222 6080

CMD ["/start.sh"]
