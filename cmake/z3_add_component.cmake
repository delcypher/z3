include(CMakeParseArguments)
define_property(GLOBAL PROPERTY Z3_LIBZ3_COMPONENTS
                BRIEF_DOCS "List of Z3 components to use in libz3"
                FULL_DOCS "List of Z3 components to use in libz3")
macro(z3_add_component component_name)
  CMAKE_PARSE_ARGUMENTS("Z3_MOD" "NOT_LIBZ3_COMPONENT" "" "SOURCES;INCLUDE_DIRS;PYG_FILES" ${ARGN})
  message(STATUS "Adding component ${component_name}")
  # Note: We don't check the sources exist here because
  # they might be generated files that don't exist yet.

  set(_list_generated_headers "")
  foreach (pyg_file ${Z3_MOD_PYG_FILES})
    set(_full_pyg_file_path "${CMAKE_CURRENT_SOURCE_DIR}/${pyg_file}")
    if (NOT (EXISTS "${_full_pyg_file_path}"))
      message(FATAL_ERROR "\"${_full_pyg_file_path}\" does not exist")
    endif()
    string(REPLACE ".pyg" ".hpp" _output_file "${pyg_file}")
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_output_file}")
      message(WARNING "\"${CMAKE_CURRENT_SOURCE_DIR}/${_output_file}\" should not exist and is polluting the source tree")
    endif()
    set(_full_output_file_path "${CMAKE_CURRENT_BINARY_DIR}/${_output_file}")
    message(STATUS "Adding rule to generate \"${_output_file}\"")
    add_custom_command(OUTPUT "${_output_file}"
      COMMAND "${PYTHON_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/scripts/pyg2hpp.py" "${_full_pyg_file_path}" "${CMAKE_CURRENT_BINARY_DIR}"
      MAIN_DEPENDENCY "${_full_pyg_file_path}"
      DEPENDS "${CMAKE_SOURCE_DIR}/scripts/pyg2hpp.py" "${CMAKE_SOURCE_DIR}/scripts/mk_util.py"
      COMMENT "Generating \"${_full_output_file_path}\" from \"${pyg_file}\""
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
      USES_TERMINAL
      VERBATIM
    )
    list(APPEND _list_generated_headers "${_full_output_file_path}")
  endforeach()
  unset(_full_include_dir_path)
  unset(_full_output_file_path)
  unset(_output_file)

  # Using "object" libraries here means we have a convenient
  # name to refer to a component in CMake but we don't actually
  # create a static/library from them.
  # FIXME: Why doesn't this realise it depends on the generated headers?
  add_library(${component_name} OBJECT ${Z3_MOD_SOURCES})
  unset(_list_generated_headers)
  # Add definitions
  foreach (define ${Z3_COMPONENT_CXX_DEFINES})
    target_compile_definitions(${component_name} PRIVATE ${define})
  endforeach()
  # Add compiler flags
  foreach (flag ${Z3_COMPONENT_CXX_FLAGS})
    target_compile_options(${component_name} PRIVATE ${flag})
  endforeach()
	# FIXME: This is gross. The way includes are added is unnecessarily complex.
  #
  # A better way to do this just to have the following include directories for
  # all sources:
  #
  # ${CMAKE_SOURCE_DIR}/src
  # ${CMAKE_BINARY_DIR}/src
  #
  # and then in sources write includes like this
  # #include "ast/rewriter/bool_rewriter.h"
  #
  # Add additional include directories
  foreach (include_dir ${Z3_MOD_INCLUDE_DIRS})
    set(_full_include_dir_path "${CMAKE_SOURCE_DIR}/src/${include_dir}")
    if (NOT (IS_DIRECTORY "${_full_include_dir_path}"))
      message(FATAL_ERROR "Specified include directory \"${_full_include_dir_path}\" does not exist")
    endif()
    target_include_directories(${component_name} PRIVATE "${_full_include_dir_path}")
    # For any generated header files
    target_include_directories(${component_name} PRIVATE "${CMAKE_BINARY_DIR}/src/${include_dir}")
    unset(_full_include_dir_path)
  endforeach()

  # For any generated header files
  target_include_directories(${component_name} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

  if (NOT Z3_MOD_NOT_LIBZ3_COMPONENT)
    # Add this component to the global list of Z3 components for libz3
    set_property(GLOBAL APPEND PROPERTY Z3_LIBZ3_COMPONENTS ${component_name})
  endif()
endmacro()

