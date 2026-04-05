# curldump
Capture, decrypt, and inspect [curl](https://curl.se/) HTTPS traffic as a `pcapng` file in [Wireshark](https://www.wireshark.org/).
This Docker image runs `curl`, records the packets, and injects the TLS session secrets into the capture so HTTPS requests can be analyzed immediately.

## Usage
```console
docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN ghcr.io/jptomoya/curldump [curl options...] <url>
```

All arguments are passed to the `curl` command.

The `NET_ADMIN` capability is required for packet capture.
The `-v $PWD:/work` option bind mounts the current directory because the output file is written to `/work` inside the container. You can mount any other directory instead if you prefer.

By default, the output file is saved as `curldump_XXXXXX.pcapng`, where `XXXXXX` is a random string. To use a specific filename, pass `-e OUTFILE=<pcapng filename>` to `docker run`.

### Example

```console
OUTFILE=example.pcapng docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump https://www.example.com/
```

You can also run `./curldump.sh` from the repository root directly on the host:

```console
OUTFILE=<pcapng file> ./curldump.sh [curl options...] <url>
```

Running the script inside Docker is recommended because it helps keep the capture free of unrelated packets.
To run `curldump.sh` directly, following tools must be installed:

* curl
* dumpcap (from `wireshark-common`)
* editcap (from `wireshark-common`)
* ss (from `iproute2`)

Open the resulting `pcapng` file in Wireshark. The HTTPS traffic will be decrypted automatically.

https://user-images.githubusercontent.com/4786564/232228733-301b3dff-6914-4c1a-918a-47cf835c5ddf.mp4

## Install

You can also create a small wrapper script and place it in your `PATH` (e.g. `/usr/local/bin/curldump`).

```console
#!/bin/sh
docker run --rm -i -v "$PWD":/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump "$@"
```

To install `curldump` into `/usr/local/bin`, open a terminal and run:

```console
sudo sh -c 'cat <<EOF > /usr/local/bin/curldump
#!/bin/sh
docker run --rm -i -v "\$PWD":/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump "\$@"
EOF'
sudo chmod +x /usr/local/bin/curldump
```

## Development
Clone the repository:

```console
git clone https://github.com/jptomoya/curldump.git
cd curldump
```

Then build the image:

```console
docker build -t curldump .
```

Mozilla removed `AAA Certification Service`, which can cause certificate errors for sites such as `example.com` in some environments. If that affects your build, you can enable a temporary workaround at build time.

```console
docker build --build-arg INSTALL_COMODO_AAA_CERT=1 -t curldump .
```

`INSTALL_COMODO_AAA_CERT` is disabled by default. This is a temporary compatibility workaround, and it is kept opt-in so the default image does not permanently carry an extra root certificate. It should be removed once the base image or the remote certificate chain no longer requires it.

After that, run the built image:

```console
docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN curldump https://www.example.com/
```
