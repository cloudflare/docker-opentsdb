FROM java:8u66-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y gnuplot && \
    apt-get clean && \
    curl -sL https://github.com/OpenTSDB/opentsdb/releases/download/v2.2.0RC3/opentsdb-2.2.0RC3_all.deb > /tmp/opentsdb.deb && \
    echo "e0f4c71f73df59dbd5101c62a34ab5b9a1967384033e23dbbfae9a550cf10b3e56c007f995c390801518d023672b81b9a8134e7f35e7f1e0a1e0f5d3f433ff0a  /tmp/opentsdb.deb" | sha512sum -c && \
    dpkg -i /tmp/opentsdb.deb && \
    rm /tmp/opentsdb.deb && \
    rm /etc/opentsdb/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
