ARG UBUNTU_VERSION=22.04
FROM ubuntu:$UBUNTU_VERSION

RUN apt-get -qq update && \
    apt-get install -yq curl libmagic-dev wget logrotate

ARG ARKIME_VERSION=4.0.3
ARG UBUNTU_VERSION
ARG ARKIME_DEB_PACKAGE="arkime_"$ARKIME_VERSION"-1_amd64.deb"

ARG ELASTIC_USERNAME
ARG ELASTIC_PASSWORD
ARG ARKIME_DIR
ARG HOST_INTERFACE

ENV ARKIME_VERSION $ARKIME_VERSION
ENV ES_HOST "elasticsearch"
ENV ES_PORT 9200
ENV ELASTIC_USERNAME $ELASTIC_USERNAME
ENV ELASTIC_PASSWORD $ELASTIC_PASSWORD
ENV ES_PORT 9200
ENV ARKIME_INTERFACE $HOST_INTERFACE
ENV ARKIME_DIR $ARKIME_DIR
ENV ARKIME_ADMIN_PASSWORD "admin"
ENV ARKIME_HOSTNAME "localhost"
ENV ARKIMEDIR "/opt/arkime"
ENV CAPTURE "on"
ENV VIEWER "on"

RUN mkdir -p /data && \
    cd /data && \
    curl -C - -O "https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-"$UBUNTU_VERSION"/"$ARKIME_DEB_PACKAGE && \
    dpkg -i $ARKIME_DEB_PACKAGE || true && \
    apt-get install -yqf && \
    mv $ARKIMEDIR/etc /data/config && \
    ln -s /data/config $ARKIMEDIR/etc && \
    ln -s /data/logs $ARKIMEDIR/logs && \
    ln -s /data/pcap $ARKIMEDIR/raw && \
    apt-get install jq -y

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* && \
    rm /data/$ARKIME_DEB_PACKAGE

ADD /scripts /data/
ADD /config/config.ini /data/config.ini

RUN chmod 755 /data/*.sh


EXPOSE 8005
WORKDIR $ARKIMEDIR

ENTRYPOINT ["/data/startarkime.sh"]