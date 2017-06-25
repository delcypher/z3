#!/bin/bash

set -x
set -e
set -o pipefail

: ${TEST_INSTALL?"TEST_INSTALL must be specified"}
: ${Z3_BUILD_DIR?"Z3_BUILD_DIR must be specified"}

cd "${Z3_BUILD_DIR}"

if [ "X${TEST_INSTALL}" = "X1" ]; then
  sudo cmake --build $(pwd) --target install
fi

# TODO: Test the installed version in some way
