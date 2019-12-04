FROM alpine:latest

RUN apk add -U curl bash
COPY ./supply-files /supply-files
COPY ./setup-zoomdata.sh /setup-zoomdata.sh

CMD /setup-zoomdata.sh
