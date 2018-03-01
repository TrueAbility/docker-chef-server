#!/bin/bash
set -e

function bail {
    MSG=$1
    echo $MSG
    exit 1
}

CHEF_BASE_URL="https://packages.chef.io/files/stable"
TMP=$(mktemp -d)

### server
SERVER_VERSION="12.17.33"
SERVER_FILE="chef-server-core_${SERVER_VERSION}-1_amd64.deb"
SERVER_SHA256="2800962092ead67747ed2cd2087b0e254eb5e1a1b169cdc162c384598e4caed5"
SERVER_URL="${CHEF_BASE_URL}/chef-server/${SERVER_VERSION}/ubuntu/16.04/${SERVER_FILE}"

### client
CLIENT_VERSION="13.8.0"
CLIENT_FILE="chef_${CLIENT_VERSION}-1_amd64.deb"
CLIENT_SHA256="da9eede634d35e5b0e04534ff4340954c09ad3974e666255acd62e090fea018e"
CLIENT_URL="${CHEF_BASE_URL}/chef/${CLIENT_VERSION}/ubuntu/16.04/${CLIENT_FILE}"

### manage
MANAGE_VERSION="2.5.8"
MANAGE_FILE="chef-manage_${MANAGE_VERSION}-1_amd64.deb"
MANAGE_SHA256="ad94997f1ab171773ab9642cf48dc734ad53138157006f59f930476666ddc45e"
MANAGE_URL="${CHEF_BASE_URL}/chef-manage/${MANAGE_VERSION}/ubuntu/16.04/${MANAGE_FILE}"


PKG=$1
case "$PKG" in
    server)
        VERSION=$SERVER_VERSION
        FILE=$SERVER_FILE
        URL=$SERVER_URL
        SHA=$SERVER_SHA256
        ;;
    
    client)
        VERSION=$CLIENT_VERSION
        FILE=$CLIENT_FILE
        URL=$CLIENT_URL
        SHA=$CLIENT_SHA256
        ;;

    manage)
        VERSION=$MANAGE_VERSION
        FILE=$MANAGE_FILE
        URL=$MANAGE_URL
        SHA=$MANAGE_SHA256
        ;;
esac

pushd $TMP
    wget -nv $URL
    echo "${SHA}  ${FILE}" | sha256sum -c
    dpkg -i $FILE
    rm -rf $FILE
popd

rm -rf $TMP

exit 0
