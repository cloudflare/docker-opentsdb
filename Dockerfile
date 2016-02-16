FROM java:8u72-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/OpenTSDB/opentsdb/releases/download/v2.2.0/opentsdb-2.2.0_all.deb > /tmp/opentsdb.deb && \
    echo "e24b119b25b292a741e5f5ea017f17fb732966b919dbd27f1b9b47f7e1a19323452ef6005e09945aa551316a7a7300b3555ef2ae4f4e6fc00f932983a5bb748b  /tmp/opentsdb.deb" | sha512sum -c && \
    dpkg -i /tmp/opentsdb.deb && \
    rm /tmp/opentsdb.deb && \
    rm /etc/opentsdb/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" > /usr/sbin/gosu && \
    echo "34049cfc713e8b74b90d6de49690fa601dc040021980812b2f1f691534be8a50  /usr/sbin/gosu" | sha256sum -c && \
    chmod +x /usr/sbin/gosu

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
