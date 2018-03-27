#!/bin/bash
KIBANA=http://kibana:5601
CURL=curl
XSRF_HEADER='kbn-xsrf:true'

# Wait for Kibana. Borrowed from https://github.com/elastic/stack-docker/blob/master/scripts/setup-beat.sh.
echo "Waiting for Kibana to spin up..."
until curl -s ${KIBANA}; do
    sleep 2
done
sleep 5

# Create our index pattern on our Logstash-ingested data.
echo "Loading index pattern..."
$CURL "${KIBANA}/api/saved_objects/index-pattern/15338860-4798-11e8-ba80-d3e7b5294494?overwrite=true" \
       -H 'Content-Type: application/json;charset=UTF-8' \
       -H 'Accept: application/json, text/plain, */*'  \
       -H ${XSRF_HEADER} \
       --data-binary '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}' 2&> /dev/null

# Import all the previously exported saved objects. There's no direct API for this, so we need to parse the 
# JSON and import each object individually.
python kibana-goodies/import.py

# And once we're done, delegate to the normal entrypoint
echo "Continuing to our regularly scheduled logstash..."
/usr/local/bin/docker-entrypoint
