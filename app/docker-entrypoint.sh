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
	sleep 25

  # If no one has passed us in a configuration volume, let's mount a fake one
	# and use that.
	if [ ! -d /config ]; then
    ln -s /usr/share/logstash/bin /config
  fi

	echo "loading templates..."
	cd /usr/share/logstash/bin/kibana-goodies && ./load.sh

	# TODO: this is a very hard-coded solution, but it's what we've got for now:
	# https://discuss.elastic.co/t/kibana-5-0-ingest-api/65043/4. Check back later
	# to see if this improves.
	curl -XPUT http://elasticsearch-master:9200/.kibana/config/5.1.2 -d '{"defaultIndex" : "logstash-*", "buildNum": 14588}'

	echo "Logging that stash!"
	set -- su-exec logstash "$@"
fi

exec "$@"
