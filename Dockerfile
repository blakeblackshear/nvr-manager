FROM jrottenberg/ffmpeg:4.2-alpine

RUN apk add inotify-tools bash

COPY watch.sh /watch.sh

RUN chmod +x /watch.sh

ENTRYPOINT [ "/watch.sh" ]