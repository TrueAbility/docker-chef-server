#!/bin/bash

LOCK="/var/opt/.run/startup.lock"

echo -n "Waiting for Chef Server Startup Lock..."
while /bin/true; do
    if [ ! -f $LOCK ]; then
        echo
        echo "done"
        echo
        break
    else
        sleep 10
        echo -n "."
    fi
done

exit 0
