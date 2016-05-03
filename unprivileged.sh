#!/bin/sh

export TSD_CACHE_CLEANUP_INTERVAL=${TSD_CACHE_CLEANUP_INTERVAL:-600}
export TSD_CACHE_MAX_AGE_MINUTES=${TSD_CACHE_MAX_AGE_MINUTES:-60}

# We have to clean up for opentsdb
# Remove files older than 1h every 10m
(while true; do
    sleep "${TSD_CACHE_CLEANUP_INTERVAL}"
    echo "$(date -u '+%F %T,000') INFO  DockerCacheCleanup: Doing cache cleanup"
    find /var/cache/opentsdb -mindepth 1 -mmin "+${TSD_CACHE_MAX_AGE_MINUTES}" -delete;
    echo "$(date -u '+%F %T,000') INFO  DockerCacheCleanup: Cache cleanup complete"
done) &

# Feeding opentsdb metrics back to itself
if [ "${TSD_TELEMETRY_INTERVAL:-0}" != "0" ]; then
    TSD_BIND=${TSD_CONF_tsd__network__bind:-127.0.0.1}
    TSD_PORT=${TSD_CONF_tsd__network__port}
    TSD_HOST=${MESOS_TASK_ID:-$(hostname -s)}

    (while true; do
        sleep "${TSD_TELEMETRY_INTERVAL}"
        echo "$(date -u '+%F %T,000') INFO  DockerOwnMetrics: Writing own metrics"
        curl --max-time 2 -s "http://$TSD_BIND:$TSD_PORT/api/stats" | \
          sed -e "s#\"host\":\"[^\"]*\"#\"host\":\"$TSD_HOST\"#g" | \
          curl --max-time 2 -s -X POST -H "Content-type: application/json" "http://$TSD_BIND:$TSD_PORT/api/put" -d @-
    done) &
fi

if [ "${1}" = "" ]; then
    exec /usr/share/opentsdb/bin/tsdb tsd --config /etc/opentsdb/opentsdb.conf
fi

exec /usr/share/opentsdb/bin/tsdb "$@" --config /etc/opentsdb/opentsdb.conf
