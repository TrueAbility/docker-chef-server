#!/bin/bash
set -e

CID="/var/opt/.run/container_id"
LOCK="/var/opt/.run/startup.lock"
INITIAL_BOOT="/var/opt/.run/initial_boot"

mkdir -p /var/opt/.run
date > $LOCK

function header {
    STR=$(echo "$1" | awk '{print toupper($0)}')
    STR_LEN=${#STR}
    MAX_LEN="50"
    HEADER_LEN=$(expr $MAX_LEN - $STR_LEN - 6)
    DASHES=$(printf "%0.s-" $(seq 1 $HEADER_LEN))
    HEADER_STR="--| $STR |$DASHES"
    echo $HEADER_STR
}

function reconfigure_plugins {
    res=$(dpkg -l chef-manage 2>/dev/null)
    if [ "$res" != "" ]; then
        header "reconfiguring chef manage"

        # fixes `chef-manage-ctl reconfigure`
        rm -rf /opt/chef-manage/service
        ln -sfv /opt/opscode/service /opt/chef-manage/service

        chef-manage-ctl reconfigure --accept-license
    fi
}

function symlink_etc_opscode {
    ### need to keep /etc/opscode persistent or end up with errors
    ### see: https://github.com/TrueAbility/docker-chef-server/issues/2
    
    # we want chef-server.rb to be consistent with
    # the docker configuration, but allow overrides in chef-server-local.rb
    mkdir -p /var/opt/opscode/etc/
    cp -a /etc/chef-server.rb /var/opt/opscode/etc/chef-server.rb

    rm -rf /etc/opscode
    ln -sfv /var/opt/opscode/etc /etc/opscode
}


### preliminary tweaks

header "setting preliminary tweaks"
sysctl net.ipv6.conf.lo.disable_ipv6=0


### initial start it up

if [ ! -f "$INITIAL_BOOT" ]; then
    mkdir -p /var/opt/opscode/{etc,log}
    touch /var/opt/opscode/etc/chef-server-local.rb
    symlink_etc_opscode

    # runit before reconfigure
    header "starting runit"
    /opt/opscode/embedded/bin/runsvdir-start &

    # this is costly to do here (since we have to do it again later)... 
    # but causes issues to install plugins if server hasn't been reconfigured
    # yet
    header "reconfiguring chef server [first boot]"
    chef-server-ctl reconfigure

    # wait for the pivotal user to be fully created before resuming
    chef-server-wait-pivotal

    # create our initial boot file so we don't cleanse again
    date > $INITIAL_BOOT
else
    # if it's not our first time booting then just start up runit
    header "starting runit"
    /opt/opscode/embedded/bin/runsvdir-start &
    symlink_etc_opscode
fi


### reconfigure if this is a new container and/or first boot

if [ ! -f "$CID" ] || [ "$(hostname)" != "$(cat $CID)" ]; then
    header "reconfiguring chef server [new container]"

    chef-server-ctl reconfigure

    # reconfigure optional plugins after chef-server-ctl reconfigure
    reconfigure_plugins
fi


### remove lock and resume

rm -f $LOCK
hostname > $CID


### handle incoming signals for clean shutdown

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
