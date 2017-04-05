#!/bin/bash
set -e

if [ "$WITH_MANAGE" == "1" ]; then
    /src/bin/install-package.sh manage
fi

exit 0
