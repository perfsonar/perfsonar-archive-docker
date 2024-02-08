#!/bin/bash

SCRIPT_PATH="${BASH_SOURCE[0]}"
if ! [ -x "$(command -v realpath)" ]; then
    if [ -L "$SCRIPT_PATH" ]; then

        [ -x "$(command -v readlink)" ] || { echo "Not able to resolve symlink. Install realpath or readlink.";exit 1; }

        # try readlink (-f not needed because we know its a symlink)
        DIR="$( cd "$( dirname $(readlink "$SCRIPT_PATH") )" && pwd -P)"
    else
        DIR="$( cd "$( dirname "$SCRIPT_PATH" )" && pwd -P)"
    fi
else
    DIR="$( cd "$( dirname "$(realpath "$SCRIPT_PATH")" )" && pwd -P)"
fi

BIN_PATH="java"

# now set the path to java: first OPENSEARCH_JAVA_HOME, then JAVA_HOME
if [ ! -z "$OPENSEARCH_JAVA_HOME" ]; then
    BIN_PATH="$OPENSEARCH_JAVA_HOME/bin/java"
elif [ ! -z "$JAVA_HOME" ]; then
    BIN_PATH="$JAVA_HOME/bin/java"
fi

"$BIN_PATH" $JAVA_OPTS -cp "$DIR/*" org.opensearch.security.tools.Hasher "$@"
