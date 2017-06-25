#!/bin/bash

set -x
set -e
set -o pipefail

: ${Z3_BUILD_DIR?"Z3_BUILD_DIR must be specified"}
: ${BUILD_DOCS?"BUILD_DOCS must be specified"}

cd "${Z3_BUILD_DIR}"

# Generate documentation
if [ "X${BUILD_DOCS}" = "X1" ]; then
  cmake --build $(pwd) --target api_docs
fi

# TODO: Test or perhaps deploy the built docs?
