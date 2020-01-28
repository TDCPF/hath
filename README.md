# H@H Docker image prepared by TDCPF
A simple container of [Hentai@Home](https://ehwiki.org/wiki/Hentai@Home) based on openjdk image and one-liner shell script only.
Had been verified in Synology Docker environment, should be no problem in others.

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

## Basic usage:
Using docker image in a VM-like docker way (instead of "designed way" docker should be used), most files can be store in the container directly.
But from the mechanism docker works and also for a better experience, link several volumes to external storage will be recommended:
- Volumes to link:
  - cache: Since the "static range" (the data your client responsible for) is distributed by HatH network, keeping the cache data is essential behavior of a good/healthy client. You can't even start the client once your cache isn't match the static zone you've been assigned for. The only solution is going to the dashboard and reset the statice zone of your client. Therefore linking cache folder out of the container is recommend.
  - download: If you're going to use the Archive Downloader feature, linking this folder out will make it easier to reach downloaded content.
- Fill ENV
  - HatH_ID: Bring the exact ID to container.
  - HatH_KEY: Bring the exact KEY to container.

One-liner shell command:
```
docker run (-it if you like to interact with it) (--rm if you want remove the container after it's stopped) --env HatH_ID=***** -e HatH_KEY=***** (--env-list if you'd like to manage environment variables with list file) imageid (command like sh if you want to debug in interactive shell)
```

Synology Docker:  
Download image from registry and deploy, fill the ENV and setup the volume link and start. Ta-da!  
(TODO: step by step screenshot)
