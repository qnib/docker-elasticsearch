#!/bin/bash


function wait_es {
    # wait for es to come up
    if [ ! $(curl -s localhost:9200|grep "ok"|grep true) ];then
        sleep 1
        wait_es
    fi
}

function wait_pid {
    if [ ! -f $1 ];then
        echo "No PID file found '${1}'"
    fi
    pid=$(cat $1)
    if [ -e /proc/$pid ];then
        sleep 5
        wait_pid ${1}
    fi
}

trap "curl -XPOST 'http://localhost:9200/_cluster/nodes/_local/_shutdown'" TERM KILL EXIT

/usr/share/elasticsearch/bin/elasticsearch -p /var/run/elasticsearch/elasticsearch.pid \
    -Des.default.path.home=/usr/share/elasticsearch \
    -Des.default.path.logs=/var/log/elasticsearch \
    -Des.default.path.data=/var/lib/elasticsearch \
    -Des.default.path.work=/tmp/elasticsearch \
    -Des.default.path.conf=/etc/elasticsearch &

sleep 10


if [ "X${ES_IDX}" != "X" ];then
    echo " Deleting index ${ES_IDX}"
    curl -XDELETE "http://localhost:9200/${ES_IDX}"
    echo '\n PUT index settings.'
    if [ -f /opt/qnib/etc/${ES_IDX}/settings.json ];then
        curl -XPUT "http://localhost:9200/${ES_IDX}/" --data-binary @/opt/qnib/etc/${ES_IDX}/settings.json
    else
        curl -XPUT "http://localhost:9200/${ES_IDX}/"
    fi
    echo '\n'
    if [ -f /opt/qnib/etc/${ES_IDX}/mappings.json ];then
        echo ' Add mappings'
        curl -XPUT "http://localhost:9200/${ES_IDX}/_mappings" --data-binary @/opt/qnib/etc/${ES_IDX}/mappings.json
        echo '\n'
    fi

fi

wait_pid /var/run/elasticsearch/elasticsearch.pid
