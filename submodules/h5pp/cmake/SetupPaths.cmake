cmake_minimum_required(VERSION 3.15)

# Append search paths for find_package and find_library calls
list(INSERT CMAKE_MODULE_PATH 0 ${PROJECT_SOURCE_DIR}/cmake)

# Make sure find_library prefers static/shared library depending on BUILD_SHARED_LIBS
# This is important when finding dependencies such as zlib which provides both shared and static libraries.
# Note that we do not force this cache variable, so users can override it
if(BUILD_SHARED_LIBS)
    # This is order is the default
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX};${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE STRING "Prefer finding shared libraries")
else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX};${CMAKE_SHARED_LIBRARY_SUFFIX} CACHE STRING "Prefer finding static libraries")
endif()

# Transform CMAKE_INSTALL_PREFIX to full path
if(DEFINED CMAKE_INSTALL_PREFIX AND NOT IS_ABSOLUTE CMAKE_INSTALL_PREFIX)
    get_filename_component(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}
            ABSOLUTE BASE_DIR ${CMAKE_BINARY_DIR} CACHE FORCE)
    message(STATUS "Setting absolute path CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
endif()

# Setup build and install directories for dependencies
if(NOT H5PP_DEPS_BUILD_DIR)
    set(H5PP_DEPS_BUILD_DIR ${CMAKE_BINARY_DIR}/h5pp-deps-build)
endif()
if(NOT H5PP_DEPS_INSTALL_DIR)
    set(H5PP_DEPS_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}) # Install to the same location as h5pp by default
endif()

if(H5PP_PREFIX_ADD_PKGNAME)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/h5pp CACHE STRING
            "The option H5PP_PREFIX_ADD_PKGNAME=ON sets the install directory: <CMAKE_INSTALL_PREFIX>/h5pp"
            FORCE)
endif()


if(WIN32)
    # On Windows it is standard practice to collect binaries into one directory.
    # This way we avoid errors from .dll's not being found at runtime.
    # These directories will contain h5pp tests, examples and possibly dependencies
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin" CACHE PATH "Collect .exe and .dll")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Collect .lib")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib" CACHE PATH "Collect .lib")
endif()


# Paths to search for conan installation.
list(APPEND H5PP_CONAN_CANDIDATE_PATHS
        ${CONAN_PREFIX}
        $ENV{CONAN_PREFIX}
        ${CONDA_PREFIX}
        $ENV{CONDA_PREFIX}
        $ENV{HOME}/anaconda3
        $ENV{HOME}/anaconda
        $ENV{HOME}/miniconda3
        $ENV{HOME}/miniconda
        $ENV{HOME}/.conda
        )

mark_as_advanced(H5PP_CONAN_CANDIDATE_PATHS)