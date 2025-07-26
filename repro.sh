#!/bin/sh
# A script that exports veriables for reproducible Linux builds based on current Git tree
# Usage: SOURCES_DIR=[kernel sources dir] ./repro.sh

cd $SOURCES_DIR
KBUILD_BUILD_USER=$(git log -1 --format='%ce' | cut -d'@' -f1)
KBUILD_BUILD_HOST=$(git log -1 --format='%ce' | cut -d'@' -f2)
KBUILD_BUILD_TIMESTAMP=$(git log -1 --format='%ci')
SOURCE_DATE_EPOCH=$(git log -1 --format='%ct')
cd - 2>/dev/null
