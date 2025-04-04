#!/bin/bash

PROPERTIES_FILE="relocate.properties"

if [ ! -f "$PROPERTIES_FILE" ]; then
    echo "Error: Properties file '$PROPERTIES_FILE' not found!"
    exit 1
fi

# Read each line, ignoring comments and empty lines.
while IFS='=' read -r key value; do
    # Skip lines that are comments or empty.
    if [[ "$key" =~ ^[[:space:]]*# ]] || [[ -z "$key" ]]; then
        continue
    fi
    # Remove carriage returns and trim whitespace from key and value.
    key=$(echo "$key" | tr -d '\r' | xargs)
    value=$(echo "$value" | tr -d '\r' | xargs)
    export "$key"="$value"
done < "$PROPERTIES_FILE"

echo "--- Koin Relocation ---"
echo " - RELOCATION_PREFIX=$RELOCATION_PREFIX"
echo " - TARGET_KOIN_VERSION=$TARGET_KOIN_VERSION"
echo " - KOIN_MODULES=$KOIN_MODULES"

export KOIN_DIR="./koin-$TARGET_KOIN_VERSION-$RELOCATION_PREFIX"
export KOIN_PROJECTS_DIR="$KOIN_DIR/projects"

rm -Rf "$KOIN_DIR"
mkdir -p "$KOIN_DIR"

echo "--- Koin Relocation ---"
echo "clone Koin ..."
./clone_koin.sh $TARGET_KOIN_VERSION

echo "Relocate package ..."
./relocate-packages.sh $RELOCATION_PREFIX

# --->

# Splitting Koin moduels names
IFS=';' read -ra KOIN_MODULES_SPLIT <<< "$KOIN_MODULES"
for KOIN_MODULE in "${KOIN_MODULES_SPLIT[@]}"; do
    # Now split each part by "/"
    IFS='/' read -ra KOIN_MODULE_PARTS <<< "$KOIN_MODULE"
    echo " module: ${KOIN_MODULE_PARTS[0]} - ${KOIN_MODULE_PARTS[1]}"
    echo "Move $KOIN_MODULE ..."
    ./relocate-module.sh ${KOIN_MODULE_PARTS[0]}/${KOIN_MODULE_PARTS[1]} $RELOCATION_PREFIX/$RELOCATION_PREFIX-${KOIN_MODULE_PARTS[1]}
done

echo "Install Koin local ..."
cd "$KOIN_PROJECTS_DIR"
./install.sh
cd ../..

rm -Rf $BUILD_DIR
mkdir -p $BUILD_DIR

echo "Copy relocated $RELOCATION_PREFIX artifacts to $BUILD_DIR ..."
cp -Rf ~/.m2/repository/io/insert-koin/$RELOCATION_PREFIX* $BUILD_DIR

echo "Update repository publication ..."
./repository-update.sh