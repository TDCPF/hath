# H@H Docker image prepared by TDCPF
A simple container of [Hentai@Home](https://ehwiki.org/wiki/Hentai@Home) based on the Amazon Corretto (Alpine, Java 8 JRE) image and a one-liner shell command only.
It has been verified in the Docker environment of Synology DSM and should work fine in others.


## ENV explanation:
- Build related (build args, they exist only while building and are not carried into the container environment):
  - HatH_VERSION: HatH version used to compose the download URL and note. It should be x.y.z most of the time.
  - HatH_DOWNLOAD_URL: HatH download URL. Should not be modified most of the time.
  - HatH_DOWNLOAD_SHA256: SHA256 hash provided at [Hentai@Home Clients dashboard](https://e-hentai.org/hentaiathome.php), used for file integrity check.
  - HatH_ARCHIVE: The filename HatH_DOWNLOAD_URL will be downloaded as.
- Execution related:
  - HatH_ID: **DO NOT FILL YOUR INFO IF YOU ARE GOING TO BUILD PUBLIC IMAGE.** The 5-digit (at the time) "Client ID#" you get from Tenboro.
  - HatH_KEY: **DO NOT FILL YOUR INFO IF YOU ARE GOING TO BUILD PUBLIC IMAGE.** The "Client Key" you get from the corresponding client configuration page at the [Hentai@Home Clients dashboard](https://e-hentai.org/hentaiathome.php).
  - HatH_PORT: The port the HatH client will use to provide traffic. It must be configured correctly on the corresponding client configuration page and be reachable from the Internet, otherwise the client will be useless.
- Optional, for file ownership on mounted volumes:
  - HatH_UID / HatH_GID: The uid/gid the HatH client runs as, both default to 1000 (same behavior as before; leave them alone if it already works for you). Set them to the owner of your mounted folders, so you don't need to grant permission to "Everyone". The container starts as root, chowns `HatH_PATH` and `HatH_PATH/data` (non-recursive; mounted volumes are never touched), then drops to this uid:gid. If you start the container with `--user`, this step is skipped.
- Execution related but recommend not to modify:
  - HatH_USER: The username which will be created in the image (with uid 1000).
  - HatH_PATH: The path the extracted HatH client will be deployed to.
  - HatH_JAR: The filename of the HatH client (inside the archive).
  - HatH_ARGS: The parameters passed to the HatH client. The list can be found at the [Hentai@Home wiki](https://ehwiki.org/wiki/Hentai@Home#Software).


## Self build:
```
docker build -t hath:tagwhateveryoulike ./
```
To build another HatH version without editing the Dockerfile, override the build args:
```
docker build --build-arg HatH_VERSION=x.y.z --build-arg HatH_DOWNLOAD_SHA256=<sha256> -t hath:tagwhateveryoulike ./
```


## Or you can use mine  
Which is built by Docker Hub according to this repository.  
https://hub.docker.com/r/tdcpf/hath


## Basic usage:
This image is used in a VM-like way (rather than the way Docker is designed to be used), so most files can be stored in the container directly.
But given how Docker works, and for a better experience, linking several volumes to external storage is recommended:
- Volumes to link:
  - cache: Since the "Static Ranges" (the data your client is responsible for) are distributed by the HatH network, keeping the cache data is essential behavior of a good/healthy client. You can't even start the client once your cache doesn't match the Static Ranges you've been assigned. The only solution is to go to the dashboard and reset the Static Ranges of your client. Therefore linking the cache folder out of the container is recommended.
  - download: If you're going to use the "Archive Downloader" feature, linking this folder outside makes the downloaded content easier to reach.
- Fill in ENV:
  - HatH_ID: Pass your exact ID to the container.
  - HatH_KEY: Pass your exact KEY to the container.


### One-liner shell command:
```
docker run (-it if you'd like to interact with it) (--rm if you want to remove the container after it's stopped) (-v /path/of/real/environment:/path/in/docker) --env HatH_ID=***** -e HatH_KEY=***** (--env-file if you'd like to manage environment variables with a file) imageid (a command like sh if you want to debug in an interactive shell)
```


### Docker@DSM (Synology Docker):
**Verified on DSM 7.0**, works like a charm.

Prerequisite:
If you'd like to keep cache files reusable and get the "Archive Downloader" results directly, you'll need two target folders (one for cache and one for download), and the container's user must be able to write to them.  
By default the service inside the container uses uid 1000 for I/O, so either:  
- set the `HatH_UID` / `HatH_GID` ENV to the uid/gid that owns those folders (recommended; you can check them via SSH with `id <username>`), or  
- grant full permission to the "Everyone" group on those folders. (Limiting it to read/write only may work too, but I haven't tried it.)  

If you don't need this, you can skip it and even the "mount volume" part below.

1. Download image from registry tab, search "tdcpf" and double click on "tdcpf/hath", using the latest tag is suggested for future updates.
2. Deploy from image tab, choose your preferred configuration, fill in the ENV and set up the mount volumes (must start with `/home/hath/client/` if you didn't change HatH_PATH), host network is preferred if you don't know anything about Docker networking.
3. Start from container tab and ta-da!

Now you should be able to see the client log in the container management interface, and the client should be online in your HatH dashboard within a few minutes.

(TODO: step by step docs)
