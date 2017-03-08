#!/bin/bash
set -e

export NO_SSL='1' # tells chef-manage ui to not force ssl redirect
CID="/var/opt/.container_id"
LOCK="/var/opt/opscode/.reconfigure.lock"

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

# function stop {
#     # stop any plugins first
#     if [ "$ENABLE_CHEF_MANAGE" == "1" ]; then
#         header "stopping chef manage"
#         chef-manage-ctl stop
#     fi
#     header "stopping chef server"
#     chef-server-ctl stop
# }

# function start {
#     header "starting chef server"
#     chef-server-ctl start

#     # start any plugins last
#     if [ "$ENABLE_CHEF_MANAGE" == "1" ]; then
#         header "starting chef manage"
#         chef-manage-ctl start
#     fi
# }

# function restart {
#     stop
#     start
# }

# function shutdown {
#     stop
#     exit 0
# }

### fixes for anything required inside the volume mounted data dir

mkdir -p /var/opt/opscode/log


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

### long running process (logs all processes to STDOUT)

header "startup complete - now watching logs longterm"

chef-server-ctl tail
