# OpenClaw Browser

A Docker container running Chromium with Chrome DevTools Protocol (CDP) and noVNC for remote browser control.

## Features

- **Chromium Browser** with CDP on port 9222
- **noVNC** web-based VNC client on port 6080
- **Chinese Font Support** (Noto CJK, WenQuanYi)
- **Configurable Resolution** via environment variables
- **Clipboard Support** for copy/paste between local and remote
- **Password Protection** for VNC access
- **Token Authentication** for CDP access

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WIDTH` | 1920 | Screen width in pixels |
| `HEIGHT` | 1080 | Screen height in pixels |
| `VNC_PASSWORD` | (empty) | VNC access password (optional) |
| `CDP_TOKEN` | (empty) | CDP access token (optional, URL parameter) |

## Quick Start

### Docker

```bash
# Build the image
docker build -t openclaw-browser .

# Run with default settings
docker run -p 9222:9222 -p 6080:6080 openclaw-browser

# Run with custom resolution
docker run -e WIDTH=1280 -e HEIGHT=720 -p 9222:9222 -p 6080:6080 openclaw-browser

# Run with password protection
docker run -e VNC_PASSWORD="your_password" -e CDP_TOKEN="your_token" -p 9222:9222 -p 6080:6080 openclaw-browser
```

## Usage

### Access noVNC

Open http://localhost:6080 in your browser. Use the VNC password if set.

**Clipboard Usage:**
- Click the clipboard icon in the noVNC toolbar
- Paste text to send to remote browser
- Copy text in remote browser to retrieve it

### Access CDP

```bash
# Without token
curl http://localhost:9222/json/version

# With token
curl http://localhost:9222/json/version?token=your_token

# WebSocket connection
ws://localhost:9222/devtools/page/...?token=your_token
```

### OpenClaw Configuration

```json
{
  "browser": {
    "profiles": {
      "remote": {
        "cdpUrl": "http://localhost:9222/json?token=your_token"
      }
    },
    "defaultProfile": "remote"
  }
}
```

## Network Access

- **CDP (9222)**: Chrome DevTools Protocol
- **noVNC (6080)**: Web-based VNC client

## Verification

```bash
# Check CDP
curl http://localhost:9222/json/version

# Access noVNC
# Open http://localhost:6080 in your browser
```

## What's Inside

- **Chromium**: Web browser with CDP
- **Xvfb**: Virtual framebuffer
- **Fluxbox**: Window manager
- **x11vnc**: VNC server
- **noVNC/websockify**: Web VNC client
- **nginx**: Reverse proxy for CDP
