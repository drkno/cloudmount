# CloudMount

Mount a remote drive for streaming. Uses of `rclone` with overlay and caching to get optimal streaming performance.

# Setup

### Create rclone configuration

Run `docker run -it --rm -v ./config:/config drkno/cloudmount:latest rclone_setup` to [setup rclone](https://rclone.org/docs/), where `./config` reflects where you want configuration files to live.

## Configuration Options

Configuration lives in `/config/cloudplow.json`, a default `cloudplow.json` will be created start if none is present.


| Configuration Option                     | Default Value  | Description                    |
|------------------------------------------|----------------|--------------------------------|
| PGID                                     | _empty_        | User GID to run as.            |
| PUID                                     | _empty_        | User UID to run as.            |
| PLEX_URL                                 | _empty_        | The PMS to empty the trash of. |
| PLEX_TOKEN                               | _empty_        | The user token for the PMS.    |
| BUFFER_SIZE                              | `500M`         | Buffer size to use when uploading / moving files |
| MAX_READ_AHEAD                           | `30G`          | The maximum number of bytes that can be prefetched for sequential reads. |
| CHECKERS                                 | `16`           | Number of checkers to run in parallel when moving/uploading. |
| RCLONE_ENDPOINT                    | `gd-crypt:`    | Raw cloud endpoint for the remote drive. |
| MAX_CACHE_FILES | `100`          | Max size of the offline file cache in GB. |
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
```

### Rclone RCD GUI

By default this container starts the [rclone rcd GUI](https://rclone.org/gui/) on port 5572 *with no authentication*.
It is expected that this GUI will either not be exposed or [run behind an SSO](https://github.com/drkno/PlexSSOv2).

## Building

```bash
docker build -t drkno/cloudmount:latest .
```
