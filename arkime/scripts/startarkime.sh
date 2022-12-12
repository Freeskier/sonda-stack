#!/bin/bash

echo "Giving OS time to start..."
until curl --cacert ${ARKIME_DIR}/config/ca.crt -sS "https://$ELASTIC_USERNAME:$ELASTIC_PASSWORD@$ES_HOST:$ES_PORT/_cluster/health?wait_for_status=yellow" > /dev/null 2>&1
do
    echo "Waiting for OS to start"
    sleep 1
done
echo
echo "OS started..."

echo "Exporting API key..."
export ELASTIC_APIKEY=$(curl --cacert ${ARKIME_DIR}/config/ca.crt -X POST -H "Content-Type: application/json" https://$ELASTIC_USERNAME:$ELASTIC_PASSWORD@$ES_HOST:$ES_PORT/_security/api_key -d '{"name":"arkime"}' | jq .encoded)

# set runtime environment variables
export ARKIME_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w32 | head -n1)  # random password
export ARKIME_LOCALELASTICSEARCH=no
export ARKIME_ELASTICSEARCH="https://"$OS_HOST":"$OS_PORT
export ARKIME_INET=no

if [ ! -f $ARKIMEDIR/etc/.initialized ]; then
    echo "Configuring......."
    echo -e "$ARKIME_LOCALELASTICSEARCH\n$ARKIME_INET" | $ARKIMEDIR/bin/Configure
    echo INIT | $ARKIMEDIR/db/db.pl --clientcert ${ARKIME_DIR}/config/arkime.crt --clientkey ${ARKIME_DIR}/config/arkime.key --insecure --esuser $ELASTIC_USERNAME:$ELASTIC_PASSWORD https://$ES_HOST:$ES_PORT init
    $ARKIMEDIR/bin/arkime_add_user.sh admin "Admin User" $ARKIME_ADMIN_PASSWORD --admin
    echo $ARKIME_VERSION > $ARKIMEDIR/etc/.initialized
else
    # possible update
    read old_ver < $ARKIMEDIR/etc/.initialized
    # detect the newer version
    newer_ver=`echo -e "$old_ver\n$ARKIME_VERSION" | sort -rV | head -n 1`
    # the old version should not be the same as the newer version
    # otherwise -> upgrade
    if [ "$old_ver" != "$newer_ver" ]; then
        echo "Upgrading OS database..."
        echo -e "$ARKIME_LOCALELASTICSEARCH\n$ARKIME_INET" | $ARKIMEDIR/bin/Configure
        $ARKIMEDIR/db/db.pl --clientcert ${ARKIME_DIR}/config/arkime.crt --clientkey ${ARKIME_DIR}/config/arkime.key --insecure --esuser $ELASTIC_USERNAME:$ELASTIC_PASSWORD https://$OS_HOST:$OS_PORT upgradenoprompt
        echo $ARKIME_VERSION > $ARKIMEDIR/etc/.initialized
    fi
fi

# start cron daemon for logrotate
service cron start

if [ "$CAPTURE" = "on" ]
then
    echo "Launch capture..."
    if [ "$VIEWER" = "on" ]
    then
        # Background execution
        exec $ARKIMEDIR/bin/capture --config $ARKIMEDIR/etc/config.ini --host $ARKIME_HOSTNAME >> $ARKIMEDIR/logs/capture.log 2>&1 &
    else
        # If only capture, foreground execution
        exec $ARKIMEDIR/bin/capture --config $ARKIMEDIR/etc/config.ini --host $ARKIME_HOSTNAME >> $ARKIMEDIR/logs/capture.log 2>&1
    fi
fi

echo "Look at log files for errors"
echo "  /data/logs/viewer.log"
echo "  /data/logs/capture.log"
echo "Visit http://127.0.0.1:8005 with your favorite browser."
echo "  user: admin"
echo "  password: $ARKIME_ADMIN_PASSWORD"

if [ "$VIEWER" = "on" ]
then
    echo "Launch viewer..."
    pushd $ARKIMEDIR/viewer
    exec $ARKIMEDIR/bin/node viewer.js -c $ARKIMEDIR/etc/config.ini --host $ARKIME_HOSTNAME >> $ARKIMEDIR/logs/viewer.log 2>&1
    popd
fi