<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.6 `/dev/tcp` and `/dev/udp`

Bash-synthesised network endpoints. These look like device files but
are intercepted by bash's redirection layer (compiled in with
`--enable-net-redirections`, on by default in mainstream
distributions).

### Form register

- `exec 3<>/dev/tcp/HOST/PORT` — open a bidirectional TCP socket on
  fd 3.
- `exec 3<>/dev/udp/HOST/PORT` — UDP equivalent.
- `cat <&3` — read incoming bytes.
- `printf '...' >&3` — send.
- `exec 3<&-` / `exec 3>&-` — close.

Limitations: no TLS (use `openssl s_client` or a real client), no
SOCKS, no IPv6 syntax in pre-5.0 bash, no name resolution beyond
what `gethostbyname(3)` does. Useful for ad-hoc diagnostics, tiny
clients without `curl`, and one-off probes.

### HTTP/1.0 probe — consolidated

```bash
# scenario: GET / over HTTP/1.0, capture the response, time-bounded
probe_http() {
  local -- host=$1 port=${2:-80} response=''

  # open
  exec 3<>"/dev/tcp/$host/$port" || return 18

  # send (HTTP/1.0 closes the connection on response — no Keep-Alive logic)
  printf 'GET / HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n' "$host" >&3

  # read with timeout per line — the server closes the socket at EOF
  while IFS= read -r -t 5 line <&3; do
    response+="$line"$'\n'
  done

  # close
  exec 3<&-
  exec 3>&-

  printf '%s' "$response"
}

probe_http example.com 80
# ⇒ HTTP/1.0 200 OK
#   Content-Type: text/html; charset=UTF-8
#   ...
```

- HTTP/1.0 with `Connection: close` so the server signals end-of-
  response by closing the socket — no `Content-Length` parsing
  needed.
- `read -t 5` per line guards against a server that opens the socket
  but never replies.
- Closing both halves of the fd (`<&-` and `>&-`) is the conservative
  form; bash 5.x cleans up the dual-direction fd on a single close.

### UDP variant

UDP is connectionless: the bash open succeeds even if no server
listens, so the only failure mode is the read-timeout:

```bash
# scenario: send a single datagram and wait briefly for a reply
probe_udp() {
  local -- host=$1 port=$2 reply=''
  exec 3<>"/dev/udp/$host/$port"
  printf 'PING\n' >&3
  read -r -t 2 reply <&3 || true
  exec 3<&-; exec 3>&-
  printf '%s\n' "$reply"
}
```

### Security caveats

- Plaintext only — credentials in any URL or header are visible on
  the wire (BCS1005, BCS1007).
- No certificate validation: `/dev/tcp` cannot do TLS at all. Reach
  for `openssl s_client -connect host:443` or `curl` for HTTPS.
- DNS lookup uses the OS resolver — affected by `/etc/hosts`,
  `/etc/resolv.conf`, NSS modules.

### When to choose `/dev/tcp` over `curl`

Almost never in production. Defensible cases: a minimal container
without `curl`, a debugging one-liner, a health-check that must not
add a `curl` dependency. Otherwise `curl --max-time 5 -fsS` or `wget
-qO-` is simpler, more robust, and TLS-capable.

### See also

- §17.4 — named pipes (host-local IPC)
- §20.x — security caveats for network IPC
- BCS1005 (input sanitization), BCS1007 (environment scrubbing before
  exec)

#fin
