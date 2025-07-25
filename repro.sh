#!/bin/sh
# A script that exports veriables for reproducible Linux builds based on current Git tree
# Usage: ./repro.sh

export KBUILD_BUILD_USER=$(git show -s --format='%ce' | cut -d'@' -f1)
export KBUILD_BUILD_HOST=$(git show -s --format='%ce' | cut -d'@' -f2)
export KBUILD_BUILD_TIMESTAMP=$(git show --no-patch --format=%ci)
