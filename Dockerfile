FROM java:8u72-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get install --no-install-recommends -y gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/OpenTSDB/opentsdb/releases/download/v2.3.0RC1/opentsdb-2.3.0-RC1_all.deb > /tmp/opentsdb.deb && \
    echo "c8503bcb09c747cffb878c28f9d121c3c0ec20164240920579bea9e4ba9c86cb0cd9d9ef75c774dbd955f388162d5df83ff2a23813d43ce7213707d7d68c7fca  /tmp/opentsdb.deb" | sha512sum -c && \
    dpkg -i /tmp/opentsdb.deb && \
    rm /tmp/opentsdb.deb && \
    rm /etc/opentsdb/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" > /usr/sbin/gosu && \
    echo "34049cfc713e8b74b90d6de49690fa601dc040021980812b2f1f691534be8a50  /usr/sbin/gosu" | sha256sum -c && \
    chmod +x /usr/sbin/gosu

COPY ./logback.xml /etc/opentsdb/logback.xml

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
