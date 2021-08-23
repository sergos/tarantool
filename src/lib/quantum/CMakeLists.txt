set(lib_sources
        quantum.c
        )

set_source_files_compile_flags(${lib_sources})
add_library(quantum STATIC ${lib_sources})
