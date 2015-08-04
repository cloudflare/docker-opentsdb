FROM java:8u45

ENV OPENTSDB_VERSION=2.1.0

RUN useradd opentsdb && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y gnuplot && \
    apt-get clean && \
    curl -sL https://github.com/OpenTSDB/opentsdb/releases/download/v${OPENTSDB_VERSION}/opentsdb-${OPENTSDB_VERSION}.tar.gz | tar zx -C /opt && \
    mv /opt/opentsdb-${OPENTSDB_VERSION} /opt/opentsdb && \
    cd /opt/opentsdb && \
    apt-get install -y make && \
    sed -i "s/MAX_NUM_TAGS = 8/MAX_NUM_TAGS = 12/" src/core/Const.java && \
    ./build.sh && \
    mkdir build/plugins && \
    rm /opt/opentsdb/src/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
