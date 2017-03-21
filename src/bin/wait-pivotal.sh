#!/bin/bash

echo -n "Waiting for Chef Server Pivotal User"
while true; do
    if [ "$(chef-server-ctl user-list 2>/dev/null| grep pivotal)" ]; then
        echo
        echo "done"
        echo
        break
    fi
    sleep 10
    echo -n "."
done

exit 0
