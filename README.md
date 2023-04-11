# curldump
A Docker image to run the curl command and save the capture file that containing the tls decryption secret.
You can immediately analyze the saved pcapng file in Wireshark.

## Usage
```console
curldump [pcapng file] [curl options...] <url>
```

pcapng file: the output filename of the pcapng file
The second and subsequent arguments are passed to the curl command.

The capture file will be saved under `/work` in the Docker container. So you need to create a bind mount for the directory you want to save the file.

## Example
Clone the repository:

    git clone https://github.com/jptomoya/curldump.git

Build the Dockerfile:

    docker build -t curldump .

Run the docker container:

    docker run -it --rm -v $PWD:/work --cap-add NET_ADMIN curldump curldump.pcapng https://www.example.com/

Then, open the saved pcapng file with Wireshark. The TLS communication will be decrypted automatically!