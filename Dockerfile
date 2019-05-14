FROM openjdk:8u212-jre

RUN useradd opentsdb && \
    apt-get update && \
    apt-get install --no-install-recommends -y gnuplot-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/OpenTSDB/opentsdb/releases/download/v2.4.0/opentsdb-2.4.0_all.deb > /tmp/opentsdb.deb && \
    echo "36cd2a7a571706e1265f26d77add40931ff4ee76c3a8756b9196852903ddf1c466cdb3960a249adee141184f3cecf2f245f849561d5569be5dd19fd5acbcda12  /tmp/opentsdb.deb" | sha512sum -c && \
    dpkg -i /tmp/opentsdb.deb && \
    rm /tmp/opentsdb.deb && \
    rm /etc/opentsdb/opentsdb.conf && \
    curl -sL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" > /usr/sbin/gosu && \
    echo "0b843df6d86e270c5b0f5cbd3c326a04e18f4b7f9b8457fa497b0454c4b138d7 /usr/sbin/gosu" | sha256sum -c && \
    chmod +x /usr/sbin/gosu

COPY ./logback.xml /etc/opentsdb/logback.xml

COPY ./run.sh /run.sh
COPY ./unprivileged.sh /unprivileged.sh

VOLUME /var/cache/opentsdb

ENTRYPOINT ["/run.sh"]
