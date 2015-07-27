# OpenTSDB in Docker

This is Mesos ready OpenTSDB TSD server docker image. Tags are corresponding
to OpenTSDB releases.

## Configuration

Containers from this image are fully configured with environment variables.
To convert OpenTSDB configuration property name to env variable name,
you should:

1. Add prefix `TSD_CONF_`
2. Replace `.` with `__`

You can also make variable name upper case. An example:

* `tsd.network.async_io` becomes `TSD_CONF_TSD__NETWORK__ASYNC_IO`

To see available configuration properties, take a look at config
[options](http://opentsdb.net/docs/build/html/user_guide/configuration.html).

## JVM options

OpenTSDB sets `JVMARGS=""-enableassertions -enablesystemassertions"`. You
can change this env variable to tune JVM. It's a good idea to set heap
size limit with `-Xmx` option:

```
JVMARGS="-Xmx1024m -enableassertions -enablesystemassertions"
```

## Cache cleanup

OpenTSDB does not support automatic cache cleanup, but cache directory
can become quite big for intense users. To fix this problem, this image
removes old cache entries from cache directory. There are two environment
variables that control cleanup process:

* `TSD_CACHE_CLEANUP_INTERVAL` interval between cleanups in seconds
* `TSD_CACHE_MAX_AGE_MINUTES` max age of cache files in minutes

## Running ad-hoc OpenTSDB commands

If you supply any args to the image, they will be passed to `tsdb` executable.
This way you could run `fsck`:

```
docker run [...] cloudflare/opentsdb:2.1.0 fsck --full-scan --fix-all --compact
```

Config is is still picked up from environment in this case.

## Security

After initial configuration container drops root privileges and runs
with dedicated `opentsdb` user.

## Example marathon configuration

```json
{
  "id": "/opentsdb/tsd",
  "container": {
    "docker": {
      "image": "cloudflare/opentsdb:2.1.0",
      "network": "HOST"
    },
    "type": "DOCKER"
  },
  "cpus": 1,
  "instances": 1,
  "mem": 1536,
  "env": {
    "VMARGS": "-Xmx1024m -enableassertions -enablesystemassertions",
    "TSD_CONF_tsd__storage__hbase__zk_quorum": "zk:2181"
  },
  "healthChecks": [
    {
      "protocol": "HTTP",
      "path": "/api/version",
      "gracePeriodSeconds": 15,
      "intervalSeconds": 10,
      "timeoutSeconds": 10,
      "maxConsecutiveFailures": 3
    }
  ]
}
```

This image is also [zoidberg](https://github.com/bobrik/zoidberg) and
[zoidberg-nginx](https://github.com/bobrik/zoidberg-nginx) friendly.

## OpenTSDB distribution changes

Util [the issue](https://github.com/OpenTSDB/opentsdb/issues/437) is resolved,
we change `MAX_NUM_TAGS` from 8 to 12 to enabled use-cases where more tags
are required.

## License

MIT
