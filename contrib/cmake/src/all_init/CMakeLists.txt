get_property(Z3_LIBZ3_COMPONENTS_LIST GLOBAL PROPERTY Z3_LIBZ3_COMPONENTS)
z3_add_component(all_init
  SOURCES
    "${CMAKE_CURRENT_BINARY_DIR}/gparams_register_modules.cpp"
    "${CMAKE_CURRENT_BINARY_DIR}/install_tactic.cpp"
    "${CMAKE_CURRENT_BINARY_DIR}/mem_initializer.cpp"
  COMPONENT_DEPENDENCIES
    ${Z3_LIBZ3_COMPONENTS_LIST}
)
z3_add_install_tactic_rule(${Z3_LIBZ3_COMPONENTS_LIST})
z3_add_memory_initializer_rule(${Z3_LIBZ3_COMPONENTS_LIST})
z3_add_gparams_register_modules_rule(${Z3_LIBZ3_COMPONENTS_LIST})
