#!/bin/bash
set -e

# Railway injects PORT at runtime; fall back to 8080 for local `docker run`.
export PORT="${PORT:-8080}"
export RESOLUTION="${RESOLUTION:-1280x800x24}"

mkdir -p /data

# If VNC_PASSWORD is set, generate the password file x11vnc will use.
# Without it, VNC has no password — fine for a quick test, not for anything
# public. Always set VNC_PASSWORD in a real deployment.
if [ -n "$VNC_PASSWORD" ]; then
    x11vnc -storepasswd "$VNC_PASSWORD" /data/vncpasswd
    echo ">> VNC password protection enabled."
else
    rm -f /data/vncpasswd
    echo ">> WARNING: no VNC_PASSWORD set — the desktop is unprotected. Set VNC_PASSWORD in Railway's environment variables."
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
