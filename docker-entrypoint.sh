#!/bin/bash

function defaults {
    : ${DEVPI_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}
    : ${DEVPI_LOGDIR="/var/log/devpi"}

    echo "DEVPI_SERVERDIR is ${DEVPI_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"
    echo "DEVPI_LOGDIR is ${DEVPI_LOGDIR}"

    export DEVPI_SERVERDIR DEVPI_CLIENTDIR DEVPI_LOGDIR
}

function initialise_devpi {
    # Start the devpi server in the background so we can initialise it.
    # Then stop it so we can instead start a server in the foreground
    # which gives us our main docker thread with log
    echo "[RUN]: Initialise devpi-server"
    devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="$DEVPI_PASSWORD"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
    devpi-server --status
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPI_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    devpi-server --restrict-modify root --host 0.0.0.0 --port 3141 2>&1 | tee $DEVPI_LOGDIR/devpi.log
    exit $?
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
