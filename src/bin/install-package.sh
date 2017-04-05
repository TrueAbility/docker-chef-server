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
SERVER_VERSION="12.14.0"
SERVER_FILE="chef-server-core_${SERVER_VERSION}-1_amd64.deb"
SERVER_SHA256="fc09bc60f22d44ff626e926c6a19eea0e7c0236ba3d4dc447c0ec01880f2b760"
SERVER_URL="${CHEF_BASE_URL}/chef-server/${SERVER_VERSION}/ubuntu/16.04/${SERVER_FILE}"

### client
CLIENT_VERSION="12.19.36"
CLIENT_FILE="chef_${CLIENT_VERSION}-1_amd64.deb"
CLIENT_SHA256="fbf44670ab5b76e4f1a1f5357885dafcc79e543ccbbe3264afd40c15d604b6dc"
CLIENT_URL="${CHEF_BASE_URL}/chef/${CLIENT_VERSION}/ubuntu/16.04/${CLIENT_FILE}"

### manage
MANAGE_VERSION="2.5.1"
MANAGE_FILE="chef-manage_${MANAGE_VERSION}-1_amd64.deb"
MANAGE_SHA256="b1ebdb94c4f9fc7da8bf549012112942061ccaf59097b5a697b008bb5b1a0fea"
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
