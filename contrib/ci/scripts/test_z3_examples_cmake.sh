#!/bin/bash

# This script tests Z3

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"

set -x
set -e
set -o pipefail
: ${Z3_SRC_DIR?"Z3_SRC_DIR must be specified"}
: ${Z3_BUILD_DIR?"Z3_BUILD_DIR must be specified"}
: ${PYTHON_BINDINGS?"PYTHON_BINDINGS must be specified"}
: ${PYTHON_EXECUTABLE?"PYTHON_EXECUTABLE must be specified"}
: ${DOTNET_BINDINGS?"DOTNET_BINDINGS must be specified"}
: ${JAVA_BINDINGS?"JAVA_BINDINGS must be specified"}

# Set compiler flags
source ${SCRIPT_DIR}/set_compiler_flags.sh

# Set CMake generator args
source ${SCRIPT_DIR}/set_generator_args.sh

cd "${Z3_BUILD_DIR}"

# Build and run C example
cmake --build $(pwd) --target c_example "${GENERATOR_ARGS[@]}"
examples/c_example_build_dir/c_example

# Build and run C++ example
cmake --build $(pwd) --target cpp_example "${GENERATOR_ARGS[@]}"
examples/cpp_example_build_dir/cpp_example

# Build and run tptp5 example
cmake --build $(pwd) --target z3_tptp5 "${GENERATOR_ARGS[@]}"
# FIXME: Do something more useful with example
examples/tptp_build_dir/z3_tptp5 -help

# Build an run c_maxsat_example
cmake --build $(pwd) --target c_maxsat_example "${GENERATOR_ARGS[@]}"
# FIXME: Once maxsat is fixed so it doesn't crash, enable running it
#./c_maxsat_example ${Z3_SRC_DIR}/src/examples/maxsat/ex.smt


if [ "X${PYTHON_BINDINGS}" = "X1" ]; then
  # Run python examples
  # `all_interval_series.py` produces a lot of output so just throw
  # away output.
  # TODO: This example is slow should we remove it from testing?
  ${PYTHON_EXECUTABLE} python/all_interval_series.py > /dev/null
  ${PYTHON_EXECUTABLE} python/complex.py
  ${PYTHON_EXECUTABLE} python/example.py
  # FIXME: `hamiltonian.py` example is disabled because its too slow.
  #${PYTHON_EXECUTABLE} python/hamiltonian.py
  ${PYTHON_EXECUTABLE} python/marco.py
  ${PYTHON_EXECUTABLE} python/mss.py
  ${PYTHON_EXECUTABLE} python/socrates.py
  ${PYTHON_EXECUTABLE} python/visitor.py
  ${PYTHON_EXECUTABLE} python/z3test.py
fi

if [ "X${DOTNET_BINDINGS}" = "X1" ]; then
  # Build .NET example
  # FIXME: Move compliation step into CMake target
  mcs ${Z3_SRC_DIR}/examples/dotnet/Program.cs /target:exe /out:dotnet_test.exe /reference:Microsoft.Z3.dll /r:System.Numerics.dll
  # Run .NET example
  mono ./dotnet_test.exe
fi

if [ "X${JAVA_BINDINGS}" = "X1" ]; then
  # Build Java example
  # FIXME: Move compilation step into CMake target
  mkdir -p examples/java
  cp ${Z3_SRC_DIR}/examples/java/JavaExample.java examples/java/
  javac examples/java/JavaExample.java -classpath com.microsoft.z3.jar
  # Run Java example
  if [ "$(uname)" = "Darwin" ]; then
    # macOS
    DYLD_LIBRARY_PATH=$(pwd) java -cp .:examples/java:com.microsoft.z3.jar JavaExample
  else
    # Assume Linux for now
    LD_LIBRARY_PATH=$(pwd) java -cp .:examples/java:com.microsoft.z3.jar JavaExample
  fi
fi

