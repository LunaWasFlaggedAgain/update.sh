#!/bin/sh

SCRIPTSDIR="$(readlink -e "$(dirname "$0")")"
SERVERDIR="$(dirname "$SCRIPTSDIR")"
WORKDIR="$SCRIPTSDIR/work"


mkdir -p "$SCRIPTSDIR/work"

build() {
    NAME=$(basename "$1" .git)
    OUT=$3
    DEST=$SERVERDIR/$4

    echo ">>> Building $NAME..."

    if cd "$NAME" 2>/dev/null; then
        git fetch || return 1

        if [ "$(git rev-parse HEAD)" = "$(git rev-parse "@{u}")" ] && [ -e "$DEST" ]; then
            # We're already up to date. No need to compile!
            cd ..
            echo "### Already up to date."
            return 0
        fi

        echo ">>> Fetching $1..."
        git pull || return 1

    else
        echo ">>> Fetching $1..."
        git clone --depth=1 "$1" "$NAME" || return 1
        cd "$NAME" || return 1
    fi

    echo ">>> Compiling $NAME..."
    eval "$cmd" || return 1

    echo ">>> Installing $NAME..."

    # shellcheck disable=SC2086
    mkdir -p "$(dirname $DEST)" || return 1
    # shellcheck disable=SC2086
    cp -v $OUT $DEST
}

echo "> Updating server files..."

while read -r line; do
    if [ "$line" = "" ]; then
        continue
    fi

    echo "$line" | while IFS="$(printf '\t')" read -r type repo cmd out dest; do
        cd "$WORKDIR" || exit 1

        if [ "$type" = "BUILD" ]; then
           if ! build "$repo" "$cmd" "$out" "$dest"; then
                echo "Got a error while building. Exiting!"
                exit 1
            fi
        elif [ "$type" = "FETCH" ]; then
            # Binary download
            echo ">>> Fetching $repo..."

            wget -q -O "$SERVERDIR/$cmd" "$repo" || exit 1
        elif [ "$type" = "GHREL" ]; then
            # GitHub release
            echo ">>> Downloading github release from $repo..."

            URL="$(curl -L "https://api.github.com/repos/$repo/releases/latest" | grep "browser_download_url" | cut -d '"' -f 4 | head -n 1)"
            echo ">>> Fetching $URL..."
            wget -q -O "$SERVERDIR/$cmd" "$URL" || exit 1
        fi

        cd "$SCRIPTSDIR" || exit 1
    done
done < "$SCRIPTSDIR/list.txt"

echo "> Done updating server files."
