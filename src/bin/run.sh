#!/bin/bash
set -e

export NO_SSL='1' # tells chef-manage ui to not force ssl redirect
CID="/var/opt/.container_id"
LOCK="/var/opt/opscode/.reconfigure.lock"
INITIAL_BOOT="/var/opt/opscode/.initial_boot"

function header {
    STR=$(echo "$1" | awk '{print toupper($0)}')
    STR_LEN=${#STR}
    MAX_LEN="50"
    HEADER_LEN=$(expr $MAX_LEN - $STR_LEN - 6)
    DASHES=$(printf "%0.s-" $(seq 1 $HEADER_LEN))
    HEADER_STR="--| $STR |$DASHES"
    echo $HEADER_STR
}

function install_plugins {
    if [ "$ENABLE_CHEF_MANAGE" == "1" ]; then
        header "installing chef manage"
        chef-server-ctl install chef-manage

        # fixes `chef-manage-ctl reconfigure`
        rm -rf /opt/chef-manage/service
        ln -sfv /opt/opscode/service /opt/chef-manage/service
    fi
}

function reconfigure_plugins {
    if [ "$ENABLE_CHEF_MANAGE" == "1" ]; then
        header "reconfiguring chef manage"
        chef-manage-ctl reconfigure --accept-license
    fi
}


### fixes for anything required inside the volume mounted data dir

if [ ! -f "$INITIAL_BOOT" ]; then
    # it's our first time ever running, so lets do a cleanse
    chef-server-ctl cleanse
    mkdir -p /var/opt/opscode/log
    touch $INITIAL_BOOT
fi

### start it up

header "starting runit"
/opt/opscode/embedded/bin/runsvdir-start &

rm -f $LOCK

if [ ! -f "$CID" ] || [ "$(hostname)" != "$(cat $CID)" ]; then
    date > $LOCK

    # install optional plugins first before chef-server-ctl reconfigure
    install_plugins

    header "reconfiguring chef server"
    chef-server-ctl reconfigure

    # reconfigure optional plugins after chef-server-ctl reconfigure
    reconfigure_plugins

    rm -f $LOCK
fi

hostname > $CID

### handle incoming signals

trap "{ chef-server-ctl hup; }" SIGHUP
trap "{ chef-server-ctl stop; exit; }" SIGINT SIGTERM

header "startup complete"

# FIX ME: can't seem to figure out how to run `tail` but also catch docker 
# stop to properly shutdown
# 
# chef-server-ctl tail
#

echo
echo "View Logs: docker exec -it [CONTAINER_ID] chef-server-ctl tail"
echo

while /bin/true; do
    sleep 10
done

chef-server-ctl stop
