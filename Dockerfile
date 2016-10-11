FROM openjdk:8u102-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get install --no-install-recommends -y gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.0RC2/opentsdb-2.3.0-RC2_all.deb > /tmp/opentsdb.deb && \
    echo "5a7e9c0d4b67538c3fcb9310b1c6550d6d0b67514fccaf3360e35fe3d2ed1e12af1a4e5658546babebf0b98cb807fee88b6cf249c5209334fe839034a6cc7b75  /tmp/opentsdb.deb" | sha512sum -c && \
    dpkg -i /tmp/opentsdb.deb && \
    rm /tmp/opentsdb.deb && \
    rm /etc/opentsdb/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" > /usr/sbin/gosu && \
    echo "5b3b03713a888cee84ecbf4582b21ac9fd46c3d935ff2d7ea25dd5055d302d3c  /usr/sbin/gosu" | sha256sum -c && \
    chmod +x /usr/sbin/gosu

COPY ./logback.xml /etc/opentsdb/logback.xml

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
