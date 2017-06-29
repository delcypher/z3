#!/bin/bash

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"

set -x
set -e
set -o pipefail

DOCKER_FILE_DIR="$(cd ${SCRIPT_DIR}/../Dockerfiles; echo $PWD)"

: ${LINUX_BASE?"LINUX_BASE must be specified"}



# Sanity check. Current working directory should be repo root
if [ ! -f "./README.md" ]; then
  echo "Current working directory should be repo root"
  exit 1
fi

BUILD_OPTS=()
# Override options if they have been provided.
# Otherwise the defaults in the Docker file will be used
if [ -n "${Z3_CMAKE_GENERATOR}" ]; then
  BUILD_OPTS+=("--build-arg" "Z3_CMAKE_GENERATOR=${Z3_CMAKE_GENERATOR}")
fi

if [ -n "${USE_OPENMP}" ]; then
  BUILD_OPTS+=("--build-arg" "USE_OPENMP=${USE_OPENMP}")
fi

if [ -n "${USE_LIBGMP}" ]; then
  BUILD_OPTS+=("--build-arg" "USE_LIBGMP=${USE_LIBGMP}")
fi

if [ -n "${BUILD_DOCS}" ]; then
  BUILD_OPTS+=("--build-arg" "BUILD_DOCS=${BUILD_DOCS}")
fi

if [ -n "${PYTHON_EXECUTABLE}" ]; then
  BUILD_OPTS+=("--build-arg" "PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
fi

if [ -n "${PYTHON_BINDINGS}" ]; then
  BUILD_OPTS+=("--build-arg" "PYTHON_BINDINGS=${PYTHON_BINDINGS}")
fi

if [ -n "${DOTNET_BINDINGS}" ]; then
  BUILD_OPTS+=("--build-arg" "DOTNET_BINDINGS=${DOTNET_BINDINGS}")
fi

if [ -n "${JAVA_BINDINGS}" ]; then
  BUILD_OPTS+=("--build-arg" "JAVA_BINDINGS=${JAVA_BINDINGS}")
fi

if [ -n "${USE_LTO}" ]; then
  BUILD_OPTS+=("--build-arg" "USE_LTO=${BUILD_DOCS}")
fi

if [ -n "${Z3_INSTALL_PREFIX}" ]; then
  BUILD_OPTS+=("--build-arg" "Z3_INSTALL_PREFIX=${Z3_INSTALL_PREFIX}")
fi

# TravisCI reserves CC for itself so use a different name
if [ -n "${C_COMPILER}" ]; then
  BUILD_OPTS+=("--build-arg" "CC=${C_COMPILER}")
fi

# TravisCI reserves CXX for itself so use a different name
if [ -n "${CXX_COMPILER}" ]; then
  BUILD_OPTS+=("--build-arg" "CXX=${CXX_COMPILER}")
fi

if [ -n "${TARGET_ARCH}" ]; then
  BUILD_OPTS+=("--build-arg" "TARGET_ARCH=${TARGET_ARCH}")
fi

if [ -n "${ASAN_BUILD}" ]; then
  BUILD_OPTS+=("--build-arg" "ASAN_BUILD=${ASAN_BUILD}")
fi

if [ -n "${UBSAN_BUILD}" ]; then
  BUILD_OPTS+=("--build-arg" "UBSAN_BUILD=${UBSAN_BUILD}")
fi

if [ -n "${TEST_INSTALL}" ]; then
  BUILD_OPTS+=("--build-arg" "TEST_INSTALL=${TEST_INSTALL}")
fi

if [ -n "${RUN_SYSTEM_TESTS}" ]; then
  BUILD_OPTS+=("--build-arg" "RUN_SYSTEM_TESTS=${RUN_SYSTEM_TESTS}")
fi

if [ -n "${Z3_SYSTEM_TEST_GIT_REVISION}" ]; then
  BUILD_OPTS+=( \
    "--build-arg" \
    "Z3_SYSTEM_TEST_GIT_REVISION=${Z3_SYSTEM_TEST_GIT_REVISION}" \
  )
fi

if [ -n "${RUN_UNIT_TESTS}" ]; then
  BUILD_OPTS+=("--build-arg" "RUN_UNIT_TESTS=${RUN_UNIT_TESTS}")
fi

if [ -n "${Z3_VERBOSE_BUILD_OUTPUT}" ]; then
  BUILD_OPTS+=( \
    "--build-arg" \
    "Z3_VERBOSE_BUILD_OUTPUT=${Z3_VERBOSE_BUILD_OUTPUT}" \
  )
fi

if [ -n "${NO_SUPPRESS_OUTPUT}" ]; then
  BUILD_OPTS+=( \
    "--build-arg" \
    "NO_SUPPRESS_OUTPUT=${NO_SUPPRESS_OUTPUT}" \
  )
fi

case ${LINUX_BASE} in
  ubuntu_14.04)
    BASE_DOCKER_FILE="${DOCKER_FILE_DIR}/z3_base_ubuntu_14.04.Dockerfile"
    BASE_DOCKER_IMAGE_NAME="z3_base_ubuntu:14.04"
    ;;
  *)
    echo "Unknown Linux base ${LINUX_BASE}"
    exit 1
    ;;
esac

# TODO: For TravisCI implement a persistent cache
# Build base image (without a context)
# The base image contains all the dependencies we want to build
# Z3.
docker build -t "${BASE_DOCKER_IMAGE_NAME}" - < "${BASE_DOCKER_FILE}"


# Now build Z3 and test it using the created base image
docker build \
  -f "${DOCKER_FILE_DIR}/z3_build.Dockerfile" \
  "${BUILD_OPTS[@]}" \
  --build-arg DOCKER_IMAGE_BASE=${BASE_DOCKER_IMAGE_NAME} \
  .
