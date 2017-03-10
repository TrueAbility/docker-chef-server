#!/bin/bash

LOCK="/var/opt/opscode/.reconfigure.lock"

echo -n "Waiting for Chef Server Reconfigure Lock"
while true; do
    if [ ! -f $LOCK ]; then
        echo
        echo "done"
        echo
        break
    fi
    sleep 10
    echo -n "."
done

exit 0
