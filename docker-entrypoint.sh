#!/usr/bin/env bash

# HUB_HOME is defined in the dockerfile
SETUP_FILE=$HUB_HOME/initial-setup-done
EXECUTABLE=$HUB_HOME/bin/hub.sh

# Easy to setup new configurations on starting
if [ "$1" == "configure" ]; then
    $EXECUTABLE "$@"
fi

# Check if there are any java options, and there are no setup file
if [ -n "$JETBRAINS_HUB_JVM_OPTIONS" ] && [ ! -f $SETUP_FILE ]; then
    echo Setting JVM Options ...

    i=0
    for opt in ${JETBRAINS_HUB_JVM_OPTIONS[@]}; do
        clOptions[$i]=-J$opt
        i=$(($i+1))
    done

    $EXECUTABLE configure ${clOptions[@]}
    touch $SETUP_FILE
fi

# Fix user/group permissions
chown -R $APP_USER:$APP_USER $HUB_HOME $HUB_DATA_DIR
chmod 740 -R $HUB_HOME $HUB_DATA_DIR

exec $EXECUTABLE run --no-browser