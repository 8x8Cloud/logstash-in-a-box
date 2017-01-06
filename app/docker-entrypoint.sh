#!/bin/bash
set -e

# This is based on the official Docker image for Logstash, found at
# https://github.com/docker-library/logstash/blob/a4b4fccbe65bc485d20508e524133fd1058dd28e/2.3/docker-entrypoint.sh.
# Please note that this entrypoint is not meant to be re-entrant, but disposable.

# Add logstash as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- logstash "$@"
fi

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
	echo "sleeping to allow cluster to spin up..."
	sleep 15

  # If no one has passed us in a configuration volume, let's mount a fake one
	# and use that.
	if [ ! -d /config ]; then
    ln -s /usr/share/logstash/bin /config
  fi

	echo "loading templates..."
	cd /usr/share/logstash/bin/kibana-goodies && ./load.sh

	echo "Logging that stash!"
	set -- su-exec logstash "$@"
fi

exec "$@"
