#!/bin/bash

set -x
set -e
set -o pipefail

: ${Z3_BUILD_DIR?"Z3_BUILD_DIR must be specified"}
: ${RUN_UNIT_TESTS?"RUN_UNIT_TESTS must be specified"}

if [ "X${RUN_UNIT_TESTS}" != "X1" ]; then
  echo "Skipping unit tests"
  exit 0
fi

cd "${Z3_BUILD_DIR}"

# Build and run internal tests
cmake --build $(pwd) --target test-z3 -- -j$(nproc)
./test-z3
