FROM ibmjava:sfj-alpine

LABEL maintainer="notexist@tdcpf.org"

## Credentials
ENV HatH_ID 5digitsID
ENV HatH_KEY 20chars&numscombiKEY

## Common settings
ENV HatH_PORT 9527

## Fetch binary
ENV HatH_VERSION 1.6.3
ENV HatH_DOWNLOAD_SHA256 55c4360fc3d635e86e08e87aebcda97aecbda3102279d41d753e7452da7c958f
ENV HatH_DOWNLOAD_URL https://repo.e-hentai.org/hath/HentaiAtHome_$HatH_VERSION.zip

## Recommend default configuration
ENV HatH_USER hath
ENV HatH_PATH "/home/$HatH_USER/client"
ENV HatH_ARCHIVE hath.zip
ENV HatH_JAR HentaiAtHome.jar
# Hentai@Home parameters: https://ehwiki.org/wiki/Hentai@Home#Software
# --Xmx????m is arg for java, not jar
ENV HatH_ARGS --disable_logging

# Container Setup
RUN adduser -D "$HatH_USER"
USER "$HatH_USER"

RUN mkdir "$HatH_PATH" && \
    cd "$HatH_PATH" && \
    wget -q "$HatH_DOWNLOAD_URL" -O "$HatH_ARCHIVE" && \
# Two spaces between hash and filename is required to pass
# TODO: seperate TEST stage with sha256 checksum verification
    echo ""$HatH_DOWNLOAD_SHA256"  "$HatH_ARCHIVE"" | sha256sum -c && \
    unzip "$HatH_ARCHIVE" "$HatH_JAR" && \
    rm "$HatH_ARCHIVE" && \
    echo $(date +%s) > ${HatH_VERSION}_${HatH_DOWNLOAD_SHA256} && \
    mkdir -p "$HatH_PATH/data" && \
    chmod -R 775 "$HatH_PATH"

WORKDIR "$HatH_PATH"

# Expose the port
EXPOSE "$HatH_PORT"

#VOLUME ["$HatH_PATH/cache", "$HatH_PATH/data", "$HatH_PATH/download"]

# TODO: HEALTHCHECK

# CMD use with ENTRYPOINT
# write credential $HatH_ID-$HatH_KEY data/client_login
CMD echo -n $HatH_ID-${HatH_KEY} > $HatH_PATH/data/client_login && java -jar "$HatH_JAR" --port=$HatH_PORT $HatH_ARGS
