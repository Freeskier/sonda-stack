FROM alpine:3.14 as builder

ENV ZEEK_VERSION 5.0.3

RUN apk add --no-cache zlib openssl libstdc++ libpcap libgcc
RUN apk add --no-cache -t .build-deps \
  bsd-compat-headers \
  libmaxminddb-dev \
  linux-headers \
  openssl-dev \
  libpcap-dev \
  python3-dev \
  zlib-dev \
  binutils \
  fts-dev \
  cmake \
  clang \
  bison \
  bash \
  swig \
  perl \
  make \
  flex \
  git \
  g++ \
  fts

RUN echo "===> Cloning zeek..." \
  && cd /tmp \
  && git clone --recursive --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git

RUN echo "===> Compiling zeek..." \
  && cd /tmp/zeek \
  && CC=clang ./configure --prefix=/usr/local/zeek \
  --build-type=MinSizeRel \
  --disable-broker-tests \
  --disable-zeekctl \
  --disable-auxtools \
  --disable-python \
  && make -j 2 \
  && make install

RUN echo "===> Compiling af_packet plugin..." \
  && cd /tmp/zeek/auxil/ \
  && git clone https://github.com/J-Gras/zeek-af_packet-plugin.git \
  && cd /tmp/zeek/auxil/zeek-af_packet-plugin \
  && CC=clang ./configure --with-kernel=/usr --zeek-dist=/tmp/zeek \
  && make -j 2 \
  && make install \
  && /usr/local/zeek/bin/zeek -NN Zeek::AF_Packet

RUN echo "===> Installing hosom/file-extraction package..." \
  && cd /tmp \
  && git clone https://github.com/hosom/file-extraction.git \
  && mv file-extraction/scripts /usr/local/zeek/share/zeek/site/file-extraction

RUN echo "===> Installing Community-Id..." \
  && cd /tmp \
  && git clone https://github.com/corelight/zeek-community-id.git \
  && cd /tmp/zeek-community-id \
  && CC=clang ./configure --zeek-dist=/tmp/zeek \
  && cd /tmp/zeek-community-id/build \
  && make -j 2 \
  && make install \
  && /usr/local/zeek/bin/zeek -NN Corelight::CommunityID

RUN echo "===> Installing corelight/json-streaming-logs package..." \
  && cd /tmp \
  && git clone https://github.com/corelight/json-streaming-logs.git json-streaming-logs \
  && find json-streaming-logs -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
  && mv json-streaming-logs/scripts /usr/local/zeek/share/zeek/site/json-streaming-logs

RUN echo "===> Size of the Zeek install..." \
  && du -sh /usr/local/zeek

WORKDIR /pcap

ENV ZEEKPATH .:/data/config:/usr/local/zeek/share/zeek:/usr/local/zeek/share/zeek/policy:/usr/local/zeek/share/zeek/site
ENV PATH $PATH:/usr/local/zeek/bin

ENTRYPOINT ["zeek"]
CMD ["-h"]