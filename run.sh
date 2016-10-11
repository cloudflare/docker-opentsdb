#!/bin/bash

set -e

export TSD_CONF_tsd__network__port=${TSD_CONF_tsd__network__port:-${PORT}}
export TSD_CONF_tsd__http__cachedir=${TSD_CONF_tsd__http__cachedir:-/var/cache/opentsdb}
export TSD_CONF_tsd__http__staticroot=${TSD_CONF_tsd__http__staticroot:-/usr/share/opentsdb/static}

export TSD_ROOT_LOG_LEVEL=${TSD_ROOT_LOG_LEVEL:-INFO}
export TSD_QUERY_LOG_LEVEL=${TSD_QUERY_LOG_LEVEL:-INFO}

if [ ! -e /etc/opentsdb/opentsdb.conf ]; then
    touch /etc/opentsdb/opentsdb.conf

    for VAR in $(env); do
        if [[ $VAR =~ ^TSD_CONF_ ]]; then
          tsd_conf_name=$(echo "$VAR" | sed -r 's/^TSD_CONF_([^=]*)=.*/\1/' | sed 's/__/./g' | tr '[:upper:]' '[:lower:]')
          tsd_conf_value=$(echo "$VAR" | sed -r "s/^[^=]*=(.*)/\1/")

          echo "$tsd_conf_name = $tsd_conf_value" >> /etc/opentsdb/opentsdb.conf
        fi
    done
fi

sed "s/{{ROOT_LOG_LEVEL}}/${TSD_ROOT_LOG_LEVEL}/"   -i /etc/opentsdb/logback.xml
sed "s/{{QUERY_LOG_LEVEL}}/${TSD_QUERY_LOG_LEVEL}/" -i /etc/opentsdb/logback.xml

chown opentsdb "${TSD_CONF_tsd__http__cachedir}"

exec gosu opentsdb /unprivileged.sh "$@"
