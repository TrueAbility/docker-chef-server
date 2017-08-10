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
SERVER_VERSION="12.15.8"
SERVER_FILE="chef-server-core_${SERVER_VERSION}-1_amd64.deb"
SERVER_SHA256="4351cc42f344292bb89b8d252b66364e79d0eb271967ef9f5debcbf3a5a6faae"
SERVER_URL="${CHEF_BASE_URL}/chef-server/${SERVER_VERSION}/ubuntu/16.04/${SERVER_FILE}"

### client
CLIENT_VERSION="13.2.20"
CLIENT_FILE="chef_${CLIENT_VERSION}-1_amd64.deb"
CLIENT_SHA256="88cd274a694bfe23d255937794744d50af972097958fa681a544479e2bfb7f6b"
CLIENT_URL="${CHEF_BASE_URL}/chef/${CLIENT_VERSION}/ubuntu/16.04/${CLIENT_FILE}"

### manage
MANAGE_VERSION="2.5.4"
MANAGE_FILE="chef-manage_${MANAGE_VERSION}-1_amd64.deb"
MANAGE_SHA256="6141a1a099c35ba224cefea7a4bd35ec07af21a3aefdcd96b307e70de652abde"
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
