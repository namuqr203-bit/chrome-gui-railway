FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    RESOLUTION=1280x800x24

# --- System deps, Xvfb, window manager, VNC stack, fonts ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        ca-certificates \
        curl \
        supervisor \
        xvfb \
        x11vnc \
        fluxbox \
        novnc \
        websockify \
        fonts-liberation \
        fonts-dejavu-core \
        libnss3 \
        libxss1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        libgbm1 \
        libxshmfence1 \
        xdotool \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# noVNC's web client sometimes lives elsewhere depending on the Debian package;
# symlink so /usr/share/novnc/vnc.html is always reachable.
RUN mkdir -p /usr/share/novnc && \
    if [ -d /usr/share/novnc ] && [ ! -f /usr/share/novnc/vnc.html ]; then \
        ln -sf /usr/share/novnc/vnc_lite.html /usr/share/novnc/vnc.html || true; \
    fi

# --- App files ---
WORKDIR /app
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Persist Chrome's profile so logins/history survive restarts if a volume is mounted here
RUN mkdir -p /data/chrome-profile

EXPOSE 8080

CMD ["/app/start.sh"]
