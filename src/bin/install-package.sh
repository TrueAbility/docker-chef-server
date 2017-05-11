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
SERVER_VERSION="12.15.6"
SERVER_FILE="chef-server-core_${SERVER_VERSION}-1_amd64.deb"
SERVER_SHA256="409849871cb5d7e17907b1b749271445ee23aae10c807cfa2521a92badfd0423"
SERVER_URL="${CHEF_BASE_URL}/chef-server/${SERVER_VERSION}/ubuntu/16.04/${SERVER_FILE}"

### client
CLIENT_VERSION="13.0.118"
CLIENT_FILE="chef_${CLIENT_VERSION}-1_amd64.deb"
CLIENT_SHA256="650e80ad44584ca48716752d411989ab155845af4af7a50c530155d9718843eb"
CLIENT_URL="${CHEF_BASE_URL}/chef/${CLIENT_VERSION}/ubuntu/16.04/${CLIENT_FILE}"

### manage
MANAGE_VERSION="2.5.3"
MANAGE_FILE="chef-manage_${MANAGE_VERSION}-1_amd64.deb"
MANAGE_SHA256="26324b4560508d953f0fe1886bac51f8f4e24f484e7e7c25ad9374e825f46421"
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
