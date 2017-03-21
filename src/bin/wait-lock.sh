#!/bin/bash

LOCK="/var/opt/.run/startup.lock"

echo -n "Waiting for Chef Server Startup Lock"
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
