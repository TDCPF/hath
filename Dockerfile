FROM amazoncorretto:8-alpine-jre

LABEL maintainer="notexist@tdcpf.org"

## Credentials
ENV HatH_ID 5digitsID
ENV HatH_KEY 20chars&numscombiKEY

## Common settings
ENV HatH_PORT 9527

## Fetch binary
ENV HatH_VERSION 1.6.6
ENV HatH_DOWNLOAD_SHA256 55a47790072384cac3c218503c0296295530eeee2d5c82e52398eff5c7fbccb5
ENV HatH_DOWNLOAD_URL https://repo.e-hentai.org/hath/HentaiAtHome_$HatH_VERSION.zip

## Recommend default configuration
ENV HatH_USER hath
# Runtime uid:gid the client runs as (container starts as root, chowns HatH_PATH and drops privilege via su-exec)
ENV HatH_UID 1000
ENV HatH_GID 1000
ENV HatH_PATH "/home/$HatH_USER/client"
ENV HatH_ARCHIVE hath.zip
ENV HatH_JAR HentaiAtHome.jar
ENV JAVA_TOOL_OPTIONS "-Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8" 
# Hentai@Home parameters: https://ehwiki.org/wiki/Hentai@Home#Software
# --Xmx????m is arg for java, not jar
ENV HatH_ARGS --disable_logging

# Container Setup
RUN apk add --no-cache su-exec && \
    adduser -D -u 1000 "$HatH_USER"
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

# Back to root so CMD can align ownership with HatH_UID/HatH_GID, then drop privilege
USER root
WORKDIR "$HatH_PATH"

# Expose the port
EXPOSE "$HatH_PORT"

#VOLUME ["$HatH_PATH/cache", "$HatH_PATH/data", "$HatH_PATH/download"]

# TODO: HEALTHCHECK

# CMD use with ENTRYPOINT
# As root: chown HatH_PATH (non-recursive, mounted volumes untouched) and data, then run as HatH_UID:HatH_GID.
# If started with --user (non-root), skip both and run as-is.
# write credential $HatH_ID-$HatH_KEY data/client_login
CMD P=; if [ "$(id -u)" = 0 ]; then chown "$HatH_UID:$HatH_GID" "$HatH_PATH" "$HatH_PATH/data" || exit 1; P="su-exec $HatH_UID:$HatH_GID"; fi; exec $P sh -c 'echo -n $HatH_ID-${HatH_KEY} > $HatH_PATH/data/client_login && exec java -jar "$HatH_JAR" --port=$HatH_PORT $HatH_ARGS'
