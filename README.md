# curldump
A Docker image to run the [curl](https://curl.se/) command and save the capture file that containing the TLS decryption secret.
You can immediately analyze the saved pcapng file in [Wireshark](https://www.wireshark.org/).

## Usage
```console
OUTFILE=<pcapng file> curldump.sh [curl options...] <url>
```

pcapng file: the output filename of the pcapng file. If the `OUTFILE` environment variable is not set, the result is saved as "curldump_XXXXXX.pcapng" in the current directory.

All arguments are passed to the curl command.

Although you can run this script from host directly, it is recommended to run the script in a Docker container to get a clean result by filtering out unrelated packets.

## Example
Clone the repository:

```console
git clone https://github.com/jptomoya/curldump.git
cd curldump
```

Build the Dockerfile:

```console
docker build -t curldump .
```

Run the docker container:

```console
docker run -it --rm -v $PWD:/work --cap-add NET_ADMIN curldump https://www.example.com/
```

The capture file will be saved under `/work` in the Docker container. Therefore, you need to create a bind mount for the directory where you want to save the file.
Use the `-e OUTFILE=<pcapng file>` option in the `docker run` command to specify the output file name.

Finally, open the saved pcapng file with Wireshark. The TLS communication will be decrypted automatically!
