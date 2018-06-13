FROM openjdk:8u102-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get install --no-install-recommends -y gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.1/opentsdb-2.3.1_all.deb > /tmp/opentsdb.deb && \
    echo "f1f118a98c4be9ae1ac5fd31bec37a7da992c4f56d3a4402ddfbf387b179dbd915386e4cb04bb415243b64f5c6b9091390cff8da386a2b765b88dc6e85db7141  /tmp/opentsdb.deb" | sha512sum -c && \
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
