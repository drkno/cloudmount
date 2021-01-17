# CloudMount

Mount a remote drive for streaming. Uses a combination of `rclone` and `plexdrive` to get optimal streaming performance.

# Setup

### Create rclone configuration

Run `docker run -it --rm -v ./config:/config drkno/cloudmount:latest rclone_setup` to [setup rclone](https://rclone.org/docs/), where `./config` reflects where you want configuration files to live.

3 remotes are needed when using encryption:
1. First one is for the Google drive connection
2. Second one is for the Google drive on-the-fly encryption/decryption
3. Third and last one is for the local encryption/decryption

 - Endpoint to your cloud storage.
    - Create new remote [**Press N**]
    - Give it a name example gd
    - Choose Google Drive [**Press 8**]
    - If you have a client id paste it here or leave it blank
    - Choose headless machine [**Press N**]
    - Open the url in your browser and enter the verification code
 - Encryption and decryption for your cloud storage.
    - Create new remote [**Press N**]
    - Give it the same name as specified in the configuration option `RCLONE_CLOUD_ENDPOINT` but without colon (:) (*default gd-crypt*)
    - Choose Encrypt/Decrypt a remote [**Press 5**]
    - Enter the name of the endpoint created in cloud-storage appended with a colon (:) and the subfolder on your cloud. Example `gd:/Media` or just `gd:` if you have your files in root in the cloud.
    - Choose how to encrypt filenames. I prefer option 2 Encrypt the filenames
    - Choose to either generate your own or random password. I prefer to enter my own.
    - Choose to enter pass phrase for the salt or leave it blank. I prefer to enter my own.
 - Encryption and decryption for your local storage.
    - Create new remote [**Press N**]
    - Give it the same name as specified in the configuration option `RCLONE_LOCAL_ENDPOINT` but without colon (:) (*default local-crypt*)
    - Choose Encrypt/Decrypt a remote [**Press 5**]
    - Enter the encrypted folder: **/config/mount**.
    - Choose the same filename encrypted as you did with the cloud storage.
    - Enter the same password as you did with the cloud storage.
    - Enter the same pass phrase as you did with the cloud storage.

### Create PlexDrive configuration

Run `docker run -it --rm -v ./config:/config drkno/cloudmount:latest plexdrive_setup` to [setup PlexDrive](https://github.com/plexdrive/plexdrive), where `./config` reflects where you want configuration files to live.

## Configuration Options

Configuration lives in `/config/cloudplow.json`, a default `cloudplow.json` will be created start if none is present.


| Configuration Option                     | Default Value  | Description                    |
|------------------------------------------|----------------|--------------------------------|
| PLEX_URL                                 | _empty_        | The PMS to empty the trash of. |
| PLEX_TOKEN                               | _empty_        | The user token for the PMS.    |
| BUFFER_SIZE                              | `500M`         | Buffer size to use when uploading / moving files |
| MAX_READ_AHEAD                           | `30G`          | The maximum number of bytes that can be prefetched for sequential reads. |
| CHECKERS                                 | `16`           | Number of checkers to run in parallel when moving/uploading. |
| RCLONE_CLOUD_ENDPOINT                    | `gd-crypt:`    | Raw cloud endpoint for the remote drive. |
| RCLONE_LOCAL_ENDPOINT                    | `local-crypt:` | Local decryption endpoint. |
| CHUNK_SIZE                               | `10M`          | The size of each chunk that is downloaded while streaming. |
| MAX_NUM_CHUNKS                           | `50`           | The maximum number of chunks to be in memory at one time while streaming. |
| CHUNK_CHECK_THREADS                      | `4`            | Number of parallel checks to perform while streaming. |
| CHUNK_LOAD_AHEAD                         | `4`            | Number of chunks to load ahead of time. |
| CHUNK_LOAD_THREADS                       | `4`            | Number of chunks to load in parallel. |
| REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB | `100`          | Remove local files when local storage exceeds this value in GB. |
| RMDELETETIME                             | `0 6 * * *`    | Cron expression defining when to delete local copies of files. `0 0 31 2 0` disables local deletions. |

## Usage

### CLI

```bash
docker run \
    --name cloudmount \
    -v ./config:/config:shared \
    -p 5572:5572/tcp \
    --privileged \
    --cap-add=MKNOD \
    --cap-add=SYS_ADMIN \
    --device=/dev/fuse \
    drkno/cloudmount:latest
```

### Docker Compose

```yaml
version: '3.4'
services:
    cloudmount:
        container_name: cloudmount
        image: drkno/cloudmount:latest
        restart: unless-stopped
        privileged: true
        cap_add:
            - MKNOD
            - SYS_ADMIN
        environment:
            - TZ=Australia/Sydney
        volumes:
            - /etc/localtime:/etc/localtime:ro
            - ./config:/config:shared
        devices:
            - /dev/fuse
        ports:
            - 5572:5572/tcp
        user: '1000:1000'
```

### Rclone RCD GUI

By default this container starts the [rclone rcd GUI](https://rclone.org/gui/) on port 5572 *with no authentication*. It is expected that this GUI will either not be exposed or [run behind an SSO](https://github.com/drkno/PlexSSOv2).

## Building

```bash
docker build -t drkno/cloudmount:latest .
```
