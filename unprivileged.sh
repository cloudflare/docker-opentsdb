#!/bin/sh

export TSD_CACHE_CLEANUP_INTERVAL=${TSD_CACHE_CLEANUP_INTERVAL:-600}
export TSD_CACHE_MAX_AGE_MINUTES=${TSD_CACHE_MAX_AGE_MINUTES:-60}

# We have to clean up for opentsdb
# Remove files older than 1h every 10m
(while true; do
    sleep "${TSD_CACHE_CLEANUP_INTERVAL}"
    echo "[$(date)] Doing cache cleanup"
    find /var/cache/opentsdb -mindepth 1 -mmin "+${TSD_CACHE_MAX_AGE_MINUTES}" -delete;
    echo "[$(date)] Cache cleanup complete"
done) &

if [ "${1}" = "" ]; then
    exec /opt/opentsdb/build/tsdb tsd --config /opt/opentsdb/src/opentsdb.conf
fi

exec /opt/opentsdb/build/tsdb "$@" --config /opt/opentsdb/src/opentsdb.conf
