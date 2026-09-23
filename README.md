# chrome-gui-railway

Runs a real, full desktop Google Chrome (same GUI you get locally) inside a
container, and streams it to your browser over the web via noVNC — so you can
deploy it on [Railway](https://railway.app) and just open a URL to see and
control Chrome's actual window.

Stack: `Xvfb` (virtual display) → `Chrome` (rendered onto it) → `x11vnc`
(captures the display) → `websockify` + `noVNC` (turns VNC into a web page on
Railway's single public port) → `supervisord` (runs it all).

## Run locally with Docker

```bash
docker build -t chrome-gui .
docker run -p 8080:8080 -e PORT=8080 -e VNC_PASSWORD=changeme chrome-gui
```

Then open **http://localhost:8080/vnc.html**, click Connect, enter the
password — you'll see the Chrome window live.

## Deploy to Railway

1. Push this repo to GitHub.
2. In Railway: **New Project → Deploy from GitHub repo** → select this repo.
   Railway detects the `Dockerfile` automatically (via `railway.toml`).
3. In the service's **Variables** tab, add:
   - `VNC_PASSWORD` = a real password (strongly recommended — without it
     anyone with the URL can control the browser)
4. Deploy. Once it's live, open the generated `*.up.railway.app` URL and go to
   `/vnc.html`.
5. (Optional) Add a Railway **Volume** mounted at `/data/chrome-profile` if
   you want Chrome's profile (logins, history, extensions) to survive
   redeploys. Without a volume, the profile resets every deploy since
   Railway's filesystem is ephemeral.

## Files

| File               | Purpose                                                         |
|--------------------|------------------------------------------------------------------|
| `Dockerfile`       | Installs Xvfb, Chrome, x11vnc, noVNC, fluxbox                   |
| `supervisord.conf` | Runs all processes together, restarts them if they crash        |
| `start.sh`         | Container entrypoint — sets up VNC password, launches supervisord|
| `railway.toml`     | Tells Railway to build from the Dockerfile                      |

## Notes / gotchas

- **Resources**: give the Railway service at least 1–2 GB RAM. Chrome + a
  desktop stack is not light.
- **Single port**: Railway only routes one public HTTP(S)/WS port per
  service, given as `$PORT`. `websockify` serves the noVNC web client *and*
  proxies the VNC WebSocket traffic on that same port — that's why there's
  only one exposed port here rather than separate VNC/web ports.
- **No headless flag**: intentionally not using `--headless`, since the whole
  point is the real rendered GUI window, not a headless automation target.
- **Security**: always set `VNC_PASSWORD` for anything beyond local testing.
  For serious use, also put the Railway URL behind Railway's own access
  controls or a reverse-auth proxy — noVNC itself has no user accounts.
- **Persistence**: mount a volume at `/data/chrome-profile` (see above) if
  you want tabs/logins to survive restarts.
