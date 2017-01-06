#!/bin/bash

# This is based on https://github.com/elastic/beats-dashboards/blob/21cbf6234a50af130dae69f2b0afb6df0204e959/load.sh
# from the Beats framework dashboards. The ElasticSearch objects were dumped using
# https://github.com/elastic/beats-dashboards/tree/master/save.
ELASTICSEARCH=http://elasticsearch-master:9200
CURL=curl
KIBANA_INDEX=".kibana"

DIR=.
echo "Loading dashboards to ${ELASTICSEARCH} in ${KIBANA_INDEX}"

for file in ${DIR}/search/*.json
do
    NAME=`basename ${file} .json`
    echo "Loading search ${NAME}:"
    ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/search/${NAME} \
        -d @${file} || exit 1
    echo
done

for file in ${DIR}/visualization/*.json
do
    NAME=`basename ${file} .json`
    echo "Loading visualization ${NAME}:"
    ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/visualization/${NAME} \
        -d @${file} || exit 1
    echo
done

for file in ${DIR}/dashboard/*.json
do
    NAME=`basename ${file} .json`
    echo "Loading dashboard ${NAME}:"
    ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/dashboard/${NAME} \
        -d @${file} || exit 1
    echo
done

for file in ${DIR}/index-pattern/*.json
do
    NAME=`awk '$1 == "\"title\":" {gsub(/[",]/, "", $2); print $2}' ${file}`
    echo "Loading index pattern ${NAME}:"

    ${CURL} -XPUT ${ELASTICSEARCH}/${KIBANA_INDEX}/index-pattern/${NAME} \
        -d @${file} || exit 1
    echo
done
