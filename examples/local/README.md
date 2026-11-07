# Local example

Applies the circuit to a throwaway Rocky Linux 10 container with systemd, titled `My homelab`, with one link to the Conn3x docs. You need Conn3x and Podman.

Homepage and Uptime Kuma run under Podman inside that container, so the host container is privileged, which is simplest with rootful Podman. On a Mac, use the Podman machine's root connection. On Linux, use `sudo podman`:

```sh
export CONTAINER_CONNECTION=podman-machine-default-root   # macOS
export PODMAN="sudo podman"                               # Linux
./up.sh
conn3x init
conn3x apply
conn3x plan
```

The first apply takes about a minute, most of it Podman installing and the two images downloading. The second plan says `No changes.`

To look at both apps in your browser, open a tunnel to the container:

```sh
ssh -N -p 2222 -i id_ed25519 -o UserKnownHostsFile=known_hosts \
  -L 3000:127.0.0.1:3000 -L 3001:127.0.0.1:3001 root@127.0.0.1
```

Then open `http://localhost:3000` for Homepage and `http://localhost:3001` for Uptime Kuma.

[`check.sh`](check.sh) is what CI runs instead of a browser. It reads `/etc/motd`, loads Homepage, finds both groups and their tiles in its API, sees Homepage's check on Uptime Kuma come back 200, and reaches Uptime Kuma's dashboard and socket.io:

```sh
podman exec -i circuit-mini-homelab bash -s < check.sh   # on Linux: sudo podman
```

`up.sh` listens on `127.0.0.1:2222`. Set `PORT` to use another port, and pass the same port to Conn3x with `-var port=PORT`. Set `CONTAINER_NAME` to name the container something other than `circuit-mini-homelab`, and pass it to `down.sh` too. Set `CONTAINERFILE` to test another distro, such as one of the images in Conn3x's `test/images`, which CI uses.

`./down.sh` removes the container, its volumes, the key and the state.
