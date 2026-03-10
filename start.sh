#!/bin/bash
set -e

# Configuration
WIDTH=${WIDTH:-1920}
HEIGHT=${HEIGHT:-1080}

# Generate nginx config
cat > /etc/nginx/sites-enabled/cdp <<EOF
server {
    listen [::]:9222;
    listen 0.0.0.0:9222;

    location / {
EOF

if [ -n "$CDP_TOKEN" ]; then
    cat >> /etc/nginx/sites-enabled/cdp <<EOF
        if (\$arg_token != "$CDP_TOKEN") { return 401; }
EOF
fi

cat >> /etc/nginx/sites-enabled/cdp <<'EOF'
        proxy_pass http://127.0.0.1:19222;
        proxy_set_header Host localhost;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Start services
mkdir -p /run/dbus && rm -f /run/dbus/pid
dbus-daemon --system --fork --nopidfile 2>/dev/null || true
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"

# Clean up X server lock files
rm -f /tmp/.X99-lock
rm -f /tmp/.X11-unix/X99

Xvfb :99 -screen 0 ${WIDTH}x${HEIGHT}x24 -ac &
export DISPLAY=:99
sleep 1

fluxbox &
sleep 1

chromium \
  --remote-debugging-port=19222 \
  --remote-allow-origins=* \
  --user-data-dir=/data/chrome-profile \
  --no-first-run \
  --no-default-browser-check \
  --disable-gpu \
  --no-sandbox \
  --start-maximized \
  about:blank &
sleep 2

nginx -g 'daemon off;' &

VNC_ARGS="-display :99 -forever -rfbport 5900 -shared"
if [ -n "$VNC_PASSWORD" ]; then
    mkdir -p /root/.vnc
    x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd
    VNC_ARGS="$VNC_ARGS -rfbauth /root/.vnc/passwd"
else
    VNC_ARGS="$VNC_ARGS -nopw"
fi

x11vnc $VNC_ARGS &
sleep 1

websockify --web /usr/share/novnc 6080 localhost:5900 &

echo "Services started: CDP=9222, VNC=5900, noVNC=6080"
wait -n
