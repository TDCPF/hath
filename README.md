# H@H Docker image prepared by TDCPF
A simple container of [Hentai@Home](https://ehwiki.org/wiki/Hentai@Home) based on openjdk image and one-liner shell script only.
Had been verified in Docker environment of Synology DSM, should be no problem in others.


## ENV explanation:
- Build related:
  - HatH_VERSION: HatH version used to composite downloading URL and note. It should be x.y.z most of time.
  - HatH_DOWNLOAD_URL: HatH download URL. Should not be modified most of time.
  - HatH_DOWNLOAD_SHA256: SHA256 hash provided at [Hentai@Home Clients dashboard](https://e-hentai.org/hentaiathome.php), used for file integrity check.
- Execution related:
  - HatH_ID: **DO NOT FILL YOUR INFO IF YOU ARE GOING TO BUILD PUBLIC IMAGE.** 5 digits (at the time) number "Client ID#" you get from Tenboro.
  - HatH_KEY: **DO NOT FILL YOUR INFO IF YOU ARE GOING TO BUILD PUBLIC IMAGE.** "Client Key" you get from [Hentai@Home Clients dashboard](https://e-hentai.org/hentaiathome.php) and enter the corresponding client configuration page.
  - HatH_PORT: The port you choose which HatH client will used to provide traffic, must be configured correctly at corresponding client configuration page and Internet reachable. Otherwise the client will be useless.
- Execution related but recommend not to modify:
  - HatH_USER: The username which will be created in image and will be used to run the HatH client.
  - HatH_PATH: The path which extracted HatH client will be deployed to.
  - HatH_ARCHIVE: The filename which HatH_DOWNLOAD_URL will be downloaded as.
  - HatH_JAR: The filename which HatH client is (inside the archive).
  - HatH_ARGS: The parameter which will be used after HatH client. The list can be found at [Hentai@Home wiki](https://ehwiki.org/wiki/Hentai@Home#Software)


## Self build:
```
docker build -t hath:tagwhateveryoulike ./
```


## Or you can use mine  
Which is built by Docker Hub according to this repository.  
https://hub.docker.com/r/tdcpf/hath


## Basic usage:
Using docker image in a VM-like docker way (instead of "designed way" docker should be used), most files can be store in the container directly.
But according to the mechanism how docker works and also for a better experience, link several volumes to external storage will be recommended:
- Volumes to link:
  - cache: Since the "static range" (the data your client responsible for) is distributed by HatH network, keeping the cache data is essential behavior of a good/healthy client. You can't even start the client once your cache isn't match the static zone you've been assigned for. The only solution is going to the dashboard and reset the statice zone of your client. Therefore linking cache folder out of the container is recommend.
  - download: If you're going to use the "Archive Downloader" feature, linking this folder outside will make it easier to reach downloaded content.
- Fill ENV
  - HatH_ID: Bring the exact ID to container.
  - HatH_KEY: Bring the exact KEY to container.


### One-liner shell command:
```
docker run (-it if you like to interact with it) (--rm if you want remove the container after it's stopped) (-v /path/of/real/environment:/path/in/docker) --env HatH_ID=***** -e HatH_KEY=***** (--env-list if you'd like to manage environment variables with list file) imageid (command like sh if you want to debug in interactive shell)
```


### Docker@DSM (Synology Docker): 
*** Verified on DSM 7.0 *** , works like a charm.

Prerequisite:
If you'd like to benefit from keeping cache files reusable and get "Archive Downloader" result directly, you'll need to have two (one for cache and one for download) target folder which provides full permission to "Everyone" group.  
(Because the service inside the container use uid 1000 to I/O by default. Limit permission to read/write only may success too but I haven't tried this way.)  
(Setting owner to 1000(Only doable via SSH shell) and set Owner required permission is also an option if you do understand what it is and how to do it.)  
If you don't, you don't need to bother this and even the "mount volume" part below.

1. Download image from registry tab, search "tdcpf" and double click on "tdcpf/hath", use latest tag is suggested for further update purpose. 
2. Deploy from image tab, choose your preferred configuartion and fill the ENV and setup the mount volume (must start with `/home/hath/client/` if you didn't change HatH_PATH), host network is preferred if you don't know anything about docker networking.
3. Start from container tab and ta-da!

Now you should be able to get client log in container management interface, and soon the client should be online in your HatH dashboard in few minutes.

(TODO: step by step docs)
