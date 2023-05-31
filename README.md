# curldump
A Docker image to run the [curl](https://curl.se/) command and save the capture file that containing the TLS decryption secret.
This can be useful for immediate analysis of the saved pcapng file in [Wireshark](https://www.wireshark.org/).

## Usage
```console
docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN ghcr.io/jptomoya/curldump [curl options...] <url>
```

All arguments are passed to the curl command.

The `NET_ADMIN` capability is needed for packet capturing.
The option `-v $PWD:/work` creates a bind mount for current directory because the capture file will be saved under `/work` in the Docker container. Of cource, you can create a bind mount for any directory where you want to save the file.

The result is saved as "curldump_XXXXXX.pcapng" (where XXXXXX is a random string). You can specify pcapng filename by setting the `OUTFILE` environment variable using `-e OUTFILE=<pcapng filename>` in the docker run options.

### Example

```console
OUTFILE=example.pcapng docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump https://www.example.com/
```

You can also run the `curldump.sh` script located in the root of the repository directly from the host as shown below:

```console
OUTFILE=<pcapng file> curldump.sh [curl options...] <url>
```

Running the script in a Docker container is recommended to obtain a clean result by filtering out unrelated packets.
To run the `curldump.sh` script, following tools must be installed.

* curl
* dumpcap (from `wireshark-common`) 
* editcap (from `wireshark-common`) 

Finally, open the saved pcapng file with Wireshark. The TLS communication will be decrypted automatically.

https://user-images.githubusercontent.com/4786564/232228733-301b3dff-6914-4c1a-918a-47cf835c5ddf.mp4

## Install

You can use the following wrapper script. Save the script into a directory in the `PATH` (e.g. `/usr/local/bin/curlcump`).

```console
#!/bin/sh
docker run --rm -i -v "$PWD":/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump "$@"
```

To install curldump into `/usr/local/bin`, open a teminal and type the following commands:

```console
sudo sh -c 'cat <<EOF > /usr/local/bin/curldump
#!/bin/sh
docker run --rm -i -v "$PWD":/work --cap-add NET_ADMIN -e OUTFILE ghcr.io/jptomoya/curldump "\$@"
EOF'
sudo chmod +x /usr/local/bin/curldump
```

## Development
Clone the repository:

```console
git clone https://github.com/jptomoya/curldump.git
cd curldump
```

Then, build the Dockerfile:

```console
docker build -t curldump .
```

Afterwards, run the built docker container:

```console
docker run -i --rm -v $PWD:/work --cap-add NET_ADMIN curldump https://www.example.com/
```
