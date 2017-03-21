#!/bin/bash
set -e 

CHEF_BASE_URL="https://packages.chef.io/files/stable/"
SERVER_VERSION="12.13.0"
SERVER_SHA256="e1c6a092f74a6b6b49b47dd92afa95be3dd9c30e6b558da5adf943a359a65997"
SERVER_BASE_URL="${CHEF_BASE_URL}/chef-server/${SERVER_VERSION}/ubuntu/16.04/"
CLIENT_VERSION="12.19.36"
CLIENT_SHA256="fbf44670ab5b76e4f1a1f5357885dafcc79e543ccbbe3264afd40c15d604b6dc"
CLIENT_BASE_URL="${CHEF_BASE_URL}/chef/${CLIENT_VERSION}/ubuntu/16.04/"
TMP=$(mktemp -d)

function header {
    STR=$(echo "$1" | awk '{print toupper($0)}')
    STR_LEN=${#STR}
    MAX_LEN="50"
    HEADER_LEN=$(expr $MAX_LEN - $STR_LEN - 6)
    DASHES=$(printf "%0.s-" $(seq 1 $HEADER_LEN))
    HEADER_STR="--| $STR |$DASHES"
    echo $HEADER_STR
}

pushd /src
    header "installing src files"
    mkdir -p /opt/opscode/sv/ /etc/opscode /etc/chef
    mv logrotate /opt/opscode/sv/logrotate
    mv chef-server.rb /etc/opscode/chef-server.rb
    mv knife.rb /etc/chef/knife.rb
    mv bin/wait-lock.sh /usr/bin/chef-server-wait-lock
    mv bin/wait-pivotal.sh /usr/bin/chef-server-wait-pivotal
popd

cd $TMP

header "installing apt system packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    logrotate \
    vim-nox \
    hardlink \
    wget \
    curl \
    ca-certificates \
    upstart-sysv \
    erlang-base \
    patch

header "downloading and verifying chef packages"
wget -nv ${SERVER_BASE_URL}/chef-server-core_${SERVER_VERSION}-1_amd64.deb
wget -nv ${CLIENT_BASE_URL}/chef_${CLIENT_VERSION}-1_amd64.deb

sha256sum -c - <<EOF
${SERVER_SHA256}  chef-server-core_${SERVER_VERSION}-1_amd64.deb
${CLIENT_SHA256}  chef_${CLIENT_VERSION}-1_amd64.deb
EOF

header "installing chef packages"
dpkg -i \
    chef-server-core_${SERVER_VERSION}-1_amd64.deb \
    chef_${CLIENT_VERSION}-1_amd64.deb

cd /

### additional setup

header "misc additional setup"
ln -sfv /var/opt/opscode/log /var/log/opscode
ln -sfv /opt/opscode/sv/logrotate /opt/opscode/service/logrotate
ln -sfv /opt/opscode/embedded/bin/sv /opt/opscode/init/logrotate

# fixes `chef-server-ctl tail` - https://github.com/chef/omnibus-ctl/pull/49
cat /src/omnibus-find-fix.diff \
    | patch /opt/opscode/embedded/lib/ruby/gems/2.2.0/gems/omnibus-ctl-0.5.0/lib/omnibus-ctl.rb

### cleanup

header "cleaning up unecessary files"
rm -rf \
    $TMP \
    /tmp/* \
    /var/tmp/* \
    /var/opt/* \
    /src/omnibus-find-fixx.diff
apt-get autoremove -y
apt-get clean -y

exit 0

