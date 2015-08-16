FROM java:8u45

ENV OPENTSDB_COMMIT=010ed96a572f33b35b570cc4c4ce80a5a97b371a

RUN useradd opentsdb && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y gnuplot git ca-certificates && \
    apt-get clean && \
    git clone -b next https://github.com/OpenTSDB/opentsdb.git /opt/opentsdb && \
    cd /opt/opentsdb && \
    git reset --hard $OPENTSDB_COMMIT && \
    apt-get install -y make automake && \
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
