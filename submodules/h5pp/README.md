[![Ubuntu 16.04](https://github.com/DavidAce/h5pp/workflows/Ubuntu%2016.04/badge.svg?branch=master)](https://github.com/DavidAce/h5pp/actions)
[![Ubuntu 20.04](https://github.com/DavidAce/h5pp/workflows/Ubuntu%2020.04/badge.svg?branch=master)](https://github.com/DavidAce/h5pp/actions)
[![Windows 10](https://github.com/DavidAce/h5pp/workflows/Windows%2010/badge.svg?branch=master)](https://github.com/DavidAce/h5pp/actions)
[![MacOS 10.15](https://github.com/DavidAce/h5pp/workflows/macOS%2010.15/badge.svg?branch=master)](https://github.com/DavidAce/h5pp/actions)
[![Download](https://img.shields.io/badge/Install%20with-conan-green)](https://conan.io/center/h5pp)
[![Download](https://img.shields.io/badge/OS-Linux%7COSX%7CWindows-blue)](https://img.shields.io/badge/OS-Linux%7COSX%7CWindows-blue)
[![codecov](https://codecov.io/gh/davidace/h5pp/branch/dev/graph/badge.svg)](https://codecov.io/gh/davidace/h5pp)

---

# h5pp
`h5pp` is a high-level C++17 wrapper for the [HDF5](https://www.hdfgroup.org/) C library.

With simplicity in mind, `h5pp` lets users store common C++ data types into portable binary [HDF5](https://www.hdfgroup.org/) files.
In particular, `h5pp` makes it easy to read and write [**Eigen**](http://eigen.tuxfamily.org) matrices and tensors.

[Latest release](https://github.com/DavidAce/h5pp/releases) 

[Documentation](https://h5pp.readthedocs.io)

Go to [quickstart](https://github.com/DavidAce/h5pp/tree/master/quickstart) to see install examples

Go to [examples](https://github.com/DavidAce/h5pp/tree/master/examples) to learn how to use `h5pp`

---

## Table of Contents
*  [Introduction](#introduction)
*  [Features](#features)
*  [Usage](#usage)
    *  [Example: Writing an std::vector](#example-writing-an-stdvector)
    *  [Debug and logging](#debug-and-logging)
    *  [File permissions](#file-permissions)
    *  [Storage layout](#storage-layout)
    *  [Compression](#compression)
    *  [Tips](#tips)
        *  [View data](#view-data)
        *  [Load data into Python](#load-data-into-python)
*  [Installation](#installation)
    *  [Requirements](#requirements)
    *  [Obtaining h5pp](#obtaining-h5pp)
    *  [Install methods](#install-methods)
        *  [Option 1: Copy the headers](#option-1-copy-the-headers)
        *  [Option 2: Install with Conan](#option-2-install-with-conan)
        *  [Option 3: Install with CMake](#option-3-install-with-cmake)
            *  [Opt-in automatic dependency installation with CMake](#opt-in-automatic-dependency-installation-with-cmake)
            *  [CMake options](#cmake-options)
    *  [Link to your project](#link-to-your-project)
        *  [Link using CMake targets (easy)](#link-using-cmake-targets-easy)
        *  [Link manually (not as easy)](#link-manually-not-as-easy)
    *  [Uninstall](#uninstall)


## Introduction
[HDF5](https://www.hdfgroup.org/) is a popular format for portable binary storage of large datasets.
With bindings to languages such as Python, Julia, Matlab and many others,
it is straightforward to export, import and analyze data in a collaborative setting.

In C/C++ using HDF5 directly is not straightforward.
Beginners are met with a steep learning curve to the vast API of HDF5.
There are many C/C++ libraries already that simplify the user experience, but as a matter of opinion,
things could be even simpler.

`h5pp` makes HDF5 simple in the following sense:
*  Read and write common C++ types in a single line of code.
*  No prior knowledge of HDF5 is required.
*  Default settings let simple tasks stay simple, e.g., storage layout, chunking and compression.
*  Advanced tasks remain possible, e.g. MPI parallelism.
*  Meaningful logs and error messages even for beginners.
*  Simple installation with modular dependencies and opt-in automation.
 

## Features
* Header-only C++17 template library
* High-level front-end to the C API of HDF5
* Modern CMake installation of `h5pp` and its dependencies (optional)
* Multi-platform: Linux, Windows, OSX. (Developed under Linux)
* Supports:
    *  all numeric types: `(u)int#_t`, `float`, `double`, `long double`
    *  **`std::complex<>`** with any of the types above
    *  CUDA-style POD-structs with `x,y` or `x,y,z` members as atomic type, such as `float3` or `double2`. These work with any of the types above. In `h5pp` these go by the name `Scalar2<>` and `Scalar3<>`.
    *  Contiguous containers with a `.data()` member, such as `std::vector<>`
    *  Text types `std::string`, `char` arrays, and `std::vector<std::string>`
    *  C-style arrays or pointer to buffer
    *  [**Eigen**](http://eigen.tuxfamily.org) types such as `Eigen::Matrix<>`, `Eigen::Array<>` and `Eigen::Tensor<>`, with automatic conversion to/from row-major storage
    *  Structs as compound HDF5 types (see [example](https://github.com/DavidAce/h5pp/blob/master/examples/example-04a-custom-struct-easy.cpp))
    *  Structs as HDF5 tables (with user-defined compound HDF5 types for entries)


## Usage
Using `h5pp` is intended to be simple. After initializing a file, 
most of the work can be achieved using just two member functions `.writeDataset(...)` and `.readDataset(...)`.

### Example: Write an `std::vector`
```c++
    #include <h5pp/h5pp.h>
    int main() {
        std::vector<double> v = {1.0, 2.0, 3.0};    // Define a vector
        h5pp::File file("somePath/someFile.h5");    // Create a file 
        file.writeDataset(v, "myStdVector");        // Write the vector into a new dataset "myStdVector"
    }
```

### Example: Read an `std::vector`
```c++
    #include <h5pp/h5pp.h>
    int main() {
        h5pp::File file("somePath/someFile.h5", h5pp::FilePermission::READWRITE);    // Open (or create) a file
        auto v = file.readDataset<std::vector<double>>("myStdVector");               // Read the dataset from file
    }
```

Find more code examples in the [examples directory](https://github.com/DavidAce/h5pp/tree/master/examples).


### File permissions
`h5pp` offers more flags for file access permissions than HDF5. The new flags are primarily intended to
prevent accidental loss of data, but also to clarify intent and avoid mutually exclusive options. 

The flags are listed in the order of increasing "danger" that they pose to previously existing files.


| Flag | File exists | No file exists | Comment |
| ---- | ---- | ---- | ---- |
| `READONLY`                | Open with read-only permission       | Throw error     | Never writes to disk, fails if the file is not found |
| `COLLISION_FAIL`          | Throw error                          | Create new file | Never deletes existing files and fails if it already exists |
| `RENAME` **(default)**    | Create renamed file                  | Create new file | Never deletes existing files. Invents a new filename to avoid collision by appending "-#" (#=1,2,3...) to the stem of the filename |
| `READWRITE`               | Open with read-write permission      | Create new file | Never deletes existing files, but is allowed to open/modify |
| `BACKUP`                  | Rename existing file and create new  | Create new file | Avoids collision by backing up the existing file, appending ".bak_#" (#=1,2,3...) to the filename |
| `REPLACE`                 | Truncate (overwrite)                 | Create new file | Deletes the existing file and creates a new one in place |


* When a new file is created, the intermediate directories are always created automatically.
* When a new file is created, `READWRITE` permission to it is implied.

To give a concrete example, the syntax works as follows

```c++
    h5pp::File file("somePath/someFile.h5", h5pp::FilePermission::REPLACE);
```

### Storage Layout
HDF5 offers three [storage layouts](https://support.hdfgroup.org/HDF5/Tutor/layout.html#lo-define):
* `H5D_COMPACT`:  For scalar or small datasets which can fit in the metadata header. Default on datasets smaller than 32 KB.
* `H5D_CONTIGUOUS`: For medium size datasets.  Default on datasets smaller than 512 KB.
* `H5D_CHUNKED`: For large datasets. Default on datasets larger than 512 KB. This layout has some additional features:
    * Chunking, portioning of the data to improve IO performance by caching more efficiently. Chunk dimensions are calculated by `h5pp` if not given by the user.
    * Compression, disabled by default, and only available if HDF5 was built with zlib enabled.
    * Resize datasets. Note that the file size never decreases, for instance after overwriting with a smaller dataset.

`h5pp` can automatically determine the storage layout for each new dataset. To specify the layout manually, pass it as a third argument when writing a new dataset, for instance:

```c++
    file.writeDataset(myData, "science/myChunkedData", H5D_CHUNKED);      // Creates a chunked dataset
```


### Compression
Extendable (or chunked) datasets can also be compressed if HDF5 was built with zlib support. Use these
functions to set or check the compression level:

```c++
    file.setCompressionLevel(3);            // 0 to 9: 0 to disable compression, 9 for maximum compression. Recommended 2 to 5
    file.getCompressionLevel();             // Gets the current compression level
    h5pp::checkIfCompressionIsAvailable();  // True if your installation of HDF5 has zlib support 
```

or pass a temporary compression level as the fifth argument when writing a dataset:
```c++
    file.writeDataset(myData, "science/myCompressedData", H5D_CHUNKED, std::nullopt, 3); // Creates a chunked dataset with compression level 3.
```

or use the shorthand member function for this task:

```c++
   file.writeDataset_compressed(myData, "science/myCompressedData", 3) // // Creates a chunked dataset with compression level 3 (default).
```




### Debug and logging
[Spdlog](https://github.com/gabime/spdlog) can be used to emit debugging information efficiently. 
The amount of console output (verbosity) can be set to any level between `0` and `5`:

* `0: trace` (highest verbosity)
* `1: debug`
* `2: info`  (default)
* `3: warn`
* `4: error`
* `5: critical`  (lowest verbosity)

Set the level when constructing a h5pp::File or by calling the function `.setLogLevel(int)`:

```c++
    int logLevel = 0; // Highest verbosity
    // This way...
    h5pp::File file("myDir/someFile.h5", h5pp::FilePermission::REPLACE, logLevel); 
    // or this way
    file.setLogLevel(logLevel);                                                                       
```

**NOTE:** Logging works the same with or without [Spdlog](https://github.com/gabime/spdlog) enabled. When Spdlog is *not* found, 
a hand-crafted logger is used in its place to give identical output but without any performance
considerations (implemented with STL lists, strings and streams).

### Tips
#### **NEW:** [h5du](https://github.com/DavidAce/h5du)
List the size of objects inside an HDF5 file with [h5du](https://github.com/DavidAce/h5du).

#### View data
Try [HDF Compass](https://support.hdfgroup.org/projects/compass) or [HDFView](https://www.hdfgroup.org/downloads/hdfview). 
Both are available in Ubuntu's package repository.


#### Load data into Python
HDF5 data is easy to load into Python using [h5py](https://docs.h5py.org/en/stable). Loading integer and floating point data is straightforward. 
Complex data is almost as simple, so let's use that as an example.

HDF5 does not support complex types natively, but `h5pp`enables this by using a custom compound HDF5 type with `real` and `imag` fields.
Here is a python example which uses [h5py](https://docs.h5py.org/en/stable) to load 1D arrays from an HDF5 file generated with `h5pp`:

```python
    import h5py
    import numpy as np
    file  = h5py.File('myFile.h5', 'r')
    
    # previously written as std::vector<double> in h5pp
    myDoubleArray = np.asarray(file['double-array-dataset'])                                     
    
    # previously written as std::vector<std::complex<double>> in h5pp
    myComplexArray = np.asarray(file['complex-double-array-dataset']).view(dtype=np.complex128) 
```
Notice the cast to `dtype=np.complex128` which interprets each element of the array as two `doubles`, i.e. the real and imaginary parts are `2 * 64 = 128` bits.  



## Installation

### Requirements
* C++17 capable compiler. GCC version >= 7 or Clang version >= 7.0
* CMake version >= 3.15
* [**HDF5**](https://support.hdfgroup.org/HDF5/)  library, version >= 1.8

#### Optional dependencies:
* [**Eigen**](http://eigen.tuxfamily.org): Write Eigen matrices and tensors directly. Tested with version >= 3.3.4
* [**spdlog**](https://github.com/gabime/spdlog): Enables logging for debug purposes. Tested with version >= 1.3.1
* [**fmt**](https://github.com/fmtlib/fmt): String formatting library (used in `spdlog`).
* [**ghc::filesystem**](https://github.com/gulrak/filesystem): If your compiler lacks `std::filesystem` this drop-in replacement is downloaded at the configuration step if `H5PP_PACKAGE_MANAGER=cmake|fetch|conan`


**NOTE:** Logging works the same with or without [Spdlog](https://github.com/gabime/spdlog) enabled. When Spdlog is *not* found, 
a hand-crafted logger is used in its place to give identical output but without any performance
considerations (implemented with STL lists, strings and streams).

### Getting h5pp
There are currently 4 ways to obtain `h5pp`:
* `git clone https://github.com/DavidAce/h5pp.git` and install (see below)
* From [conan-center](https://conan.io/center/h5pp/1.9.0)
* (Ubuntu/Debian only) Download the [latest release](https://github.com/DavidAce/h5pp/releases) and install with apt: `sudo apt install ./h5pp_<version>_amd64.deb` 


### Install methods

For full working examples see the directory [quickstart](https://github.com/DavidAce/h5pp/tree/master/quickstart). Find a summary below.

#### Option 1: Copy the headers
Copy the files under `h5pp/source/include` and add `#include<h5pp/h5pp.h>`.
Make sure to compile with `-std=c++17 -lstdc++fs` and link the dependencies `HDF5`, `Eigen3`, `fmt`, and `spdlog`. The actual linking
is a non-trivial step, see [linking](#linking) below.


#### Option 2: Install with Conan (Recommended)
Make sure to install and configure Conan first. You may need to add the line `compiler.cppstd=17` under `[settings]` in your conan profile `~/.conan/profile/default`.
Then run the following command:

```
$ conan install h5pp/1.9.0@ --build=missing
```

The flag `--build=missing` lets conan install dependencies: `HDF5`, `Eigen` and `fmt` and `spdlog`.

After this step, use `h5pp` like any other conan package. 
For more information refer to the [conan docs](https://docs.conan.io/en/latest/getting_started.html) or have a look at [quickstart](https://github.com/DavidAce/h5pp/tree/master/quickstart).


#### Option 3: Git clone + CMake install
After cloning this repository, build the library just as any CMake project. For example, run the following commands:

```bash
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=<install-dir>  <source-dir>
    make
    make install
```

Headers will be installed under `<install-dir>/include` and config files under `<install-dir>/share/h5pp/cmake`.
These config files allow you to use`find_package(h5pp)` in your own projects, which in turn defines the target `h5pp::h5pp` 
with everything you need to link `h5pp` correctly (including dependencies, if you so choose). 

##### Opt-in automatic dependency installation with CMake
The CMake flag `H5PP_PACKAGE_MANAGER` controls the automated behavior for finding or installing dependencies. It can take one of these strings:

| Option | Description |
| ---- | ---- |
| `none`                            | Skip handling dependencies  |
| `find` **(default)**              | Use CMake's `find_package`  to find dependencies  |
| `cmake` **¹**                     | Use isolated CMake instances to download and install dependencies during configure. Disregards pre-installed dependencies on your system |
| `fetch` **²**                     | Use FetchContent to download and install dependencies. Disregards pre-installed dependencies on your system |
| `cpm` **³**                       | Use [https://github.com/cpm-cmake/CPM.cmake](CPM)to download and install dependencies. Disregards pre-installed dependencies on your system |
| `find-or-cmake`                   | Start with `find` and then go to `cmake` if not found |
| `find-or-fetch`                   | Start with `find` and then go to `fetch` if not found |
| `find-or-cpm`                     | Start with `find` and then go to `cpm` if not found   |
| `conan` **⁴**                     | Use the [Conan package manager](https://conan.io/) to download and install dependencies automatically. Disregards libraries elsewhere on your system  |

There are several variables you can pass to CMake to guide `find_package` calls and install location, see [CMake options](#cmake-options) below. 

**¹** Dependencies are installed into `${H5PP_DEPS_INSTALL_DIR}[/<PackageName>]`, where `H5PP_DEPS_INSTALL_DIR` defaults to `CMAKE_INSTALL_PREFIX` and optionally `/<PackageName>` is added if `H5PP_PREFIX_ADD_PKGNAME=TRUE`

**²** Dependencies are installed into `${CMAKE_INSTALL_PREFIX}[/<PackageName>]`.

**³** Dependencies are installed into `${CMAKE_INSTALL_PREFIX}`.

**⁴** Conan is guided by `conanfile.txt` found in this project's root directory. This method requires conan to be installed prior (for instance through `pip`, `conda`, `apt`, etc). To let CMake find conan you have three options:
  * Add Conan install (or bin) directory to the environment variable `PATH`.
  * Export Conan install (or bin) directory in the environment variable `CONAN_PREFIX`, i.e. from command line: `export CONAN_PREFIX=<path-to-conan>` 
  * Give the variable `CONAN_PREFIX` directly to CMake, i.e. from command line: `cmake -DCONAN_PREFIX:PATH=<path-to-conan> ...`

##### CMake options

The `cmake` step above takes several options, `cmake [-DOPTIONS=var] ../ `:

| Var | Default | Description |
| ---- | ---- | ---- |
| `H5PP_ENABLE_EIGEN3`              | `OFF`                     | Enables `Eigen` linear algebra library support |
| `H5PP_ENABLE_FMT`                 | `OFF`                     | Enables `{fmt}` string formatting library |
| `H5PP_ENABLE_SPDLOG`              | `OFF`                     | Enables `spdlog` support for logging `h5pp` internal info to stdout (implies fmt) |
| `H5PP_PACKAGE_MANAGER`            | `find`                    | Download method for dependencies, select, `find`, `cmake`,`fetch`, `cpm`, `find-or-cmake`, `find-or-fetch` or `conan` |
| `BUILD_SHARED_LIBS`               | `OFF`                     | Link dependencies with static or shared libraries    |
| `CMAKE_INSTALL_PREFIX`            | None                      | Install directory for `h5pp` and dependencies  |
| `H5PP_DEPS_INSTALL_DIR`           | `CMAKE_INSTALL_PREFIX`    | Install directory for dependencies only (if a different one is desired) |
| `H5PP_PREFIX_ADD_PKGNAME`         | `OFF`                     | Appends `<PackageName>` to install location of dependencies, i.e. `${H5PP_DEPS_INSTALL_DIR}/<PackageName>`. This allows simple removal |
| `H5PP_ENABLE_PCH`                 | `OFF`                     | Use precompiled headers to speed up compilation of tests and examples |
| `H5PP_ENABLE_CCACHE`              | `OFF`                     | Use ccache to speed up compilation of tests and examples |
| `H5PP_ENABLE_TESTS`               | `OFF`                     | Build tests (recommended!) |
| `H5PP_BUILD_EXAMPLES`             | `OFF`                     | Build example programs |
| `H5PP_IS_SUBPROJECT`              | `OFF`                     | Use `h5pp` with add_subdirectory(). Skips installation of targets if true. Automatic detection if not set |
| `H5PP_PRINT_INFO`                 | `OFF`                     | Print extra CMake info about the host and generated targets during configure |
| `CONAN_PREFIX`                    | None                      | conan install directory  |

In addition, variables such as [`<PackageName>_ROOT`](https://cmake.org/cmake/help/latest/variable/PackageName_ROOT.html) and [`<PackageName>_DIR`](https://cmake.org/cmake/help/latest/command/find_package.html) can be set to help guide CMake's `find_package` calls:


## Link to your project

### Link using CMake targets (easy)
`h5pp` is easily imported into your project using CMake's `find_package`. Just point it to the `h5pp` install directory.
When found, targets are made available to compile and link to dependencies correctly.
A minimal `CMakeLists.txt` to use `h5pp` would look like:


```cmake
    cmake_minimum_required(VERSION 3.18)
    project(myProject)
    add_executable(myExecutable main.cpp)
    find_package(h5pp HINTS <h5pp-root-dir> REQUIRED)
    target_link_libraries(myExecutable PRIVATE h5pp::h5pp)
```


#### Targets explained

*  `h5pp::h5pp` is the main target including "everything" and should normally be the only target that you need -- headers,flags and (if enabled) the found/downloaded dependencies.
*  `h5pp::headers` links the `h5pp` headers only.
*  `h5pp::deps` collects targets to link all the dependencies that were found/downloaded when `h5pp` was installed. These can of course be used independently.
    * If `H5PP_PACKAGE_MANAGER==find|cmake|fetch|cmp` the targets are `Eigen3::Eigen`,`fmt::fmt`, `spdlog::spdlog` and `hdf5::all`, 
    * If `H5PP_PACKAGE_MANAGER==conan` the targets are `CONAN_PKG::eigen`,`CONAN_PKG::fmt`, `CONAN_PKG::spdlog` and `CONAN_PKG::hdf5`. 
*  `h5pp::flags` sets compile and linker flags to  enable C++17 and std::filesystem library, i.e. `-std=c++17` and `-lstdc++fs`. 
    On `MSVC` it sets `/permissive-` to enable logical `and`/`or` in C++. 


### Link manually (not as easy)
From the command-line you can of course link using linker flags such as `-std=c++17 -lstdc++fs -leigen3 -lfmt -lspdlog -lhdf5_hl -lhdf5` provided these flags make sense on your system.
You could also use CMake's `find_package(...)` mechanism. A minimal `CMakeLists.txt` could be something like:

```cmake
    cmake_minimum_required(VERSION 3.18)
    project(myProject)
    
    add_executable(myExecutable main.cpp)
    target_include_directories(myExecutable PRIVATE <path-to-h5pp-headers>)
    # Setup h5pp
    target_compile_features(myExecutable PRIVATE cxx_std_17)
    target_link_libraries(myExecutable PRIVATE  stdc++fs) # To get <filesystem> headers working. Not needed after GCC 9.1 
    
    # CMake versions >= 3.19 bundle a good FindHDF5.cmake module to use with find_package
    find_package(HDF5 1.8 COMPONENTS C HL REQUIRED)  # Note that h5pp only needs the C libs of HDF5.
    target_link_libraries(myExecutable PRIVATE hdf5::hdf5_hl hdf5::hdf5) # *Should* take care of everything.
    # Otherwise HDF5 has to be linked manually. 
    # target_link_libraries(myExecutable PRIVATE hdf5_hl hdf5 rt dl m z pthread) # Possibly more libs, such as aec, dependending on your HDF5 installation
    # target_include_directories(myExecutable PRIVATE <path-to-HDF5-include-dir>)


    # The other dependencies lack find_package modules bundled with CMake, so this can be trickier.
    # You can
    #   1) Use find_package() to find installed packages in config-mode in your system
    #   2) Use find_library() + add_library() to find libfmt, libspdlog in your system.
    #   3) Just link -lfmt, -lspdlog and hope that these libraries are found by the linker.
    target_link_libraries(myExecutable PRIVATE spdlog fmt)
    target_include_directories(myExecutable PRIVATE <path-to-Eigen3-include-dir>)
    target_include_directories(myExecutable PRIVATE <path-to-fmt-include-dir>)
    target_include_directories(myExecutable PRIVATE <path-to-spdlog-include-dir>)



```

The difficult part is linking to HDF5 libraries and its dependencies.
#### Use the custom FindHDF5.cmake bundled with `h5pp`
When installing `h5pp`, finding HDF5 and setting up the CMake target `hdf5::all` for linking is handled by a custom module for finding HDF5, defined in `cmake/FindHDF5.cmake`. 
This module wraps the default `FindHDF5.cmake` which comes with CMake and uses the same call signature, but fixes some annoyances with naming conventions in different versions of CMake and HDF5 executables.
It reads hints passed through CMake flags to find HDF5 somewhere on your system (can be installed via,`apt`,`yum`, `brew`, `Easybuild`, etc) and defines a CMake target `hdf5::all` with everything you need to link correctly.
Most importantly, it avoids injecting shared versions of libraries (dl, zlib, szip, aec) during static builds on older platforms.
You can use the custom module too. Add the path pointing to `FindHDF5.cmake` to the variable `CMAKE_MODULE_PATH` from within your own project:

```cmake
    list(APPEND CMAKE_MODULE_PATH path/to/h5pp/cmake/FindHDF5.cmake) # Replaces the bundled FindHDF5.cmake module
    find_package(HDF5 1.10 COMPONENTS C HL REQUIRED)
    if(TARGET hdf5::all)
            target_link_libraries(myExecutable PRIVATE hdf5::all)
    endif()
```

These are variables that can be used to guide the custom `FindHDF5.cmake` module:

| Var | Where | Description |
| ---- | ---- | ---- |
| `CMAKE_MODULE_PATH`    | CMake     | List of directories where `CMake` should search for find-modules |
| `CMAKE_PREFIX_PATH`    | CMake     | List of directories where `find_package` should look for dependencies|
| `HDF5_ROOT`            | CMake/ENV | Path to HDF5 root install directory    |
| `HDF5_FIND_VERBOSE`    | CMake     | Prints more information about the search for HDF5. See also `HDF5_FIND_DEBUG` in the original module |
| `EBROOTHDF5`           | ENV       | Variable defined by Easybuild with `module load HDF5` |


  
## Uninstall

The target `uninstall` is defined by `h5pp` which removes installed headers and dependencies using their respective install manifests.
From the build directory, run the following in the command-line to uninstall:


```
    cmake --build .  --target uninstall
```

# To-do
In no particular order

* Expand documentation. Perhaps a doxygen/sphinx webpage
* Expand testing for more edge-cases in
    * filesystem permissions
    * user-defined types
    * tables
* Expose more of the C-API:
    * Support for packed user-defined types. Read more: [H5TPack](https://support.hdfgroup.org/HDF5/doc/RM/RM_H5T.html#Datatype-Pack)
    * True support for parallel read/write with MPI
* Support row-major <-> col-major transformation for types other than Eigen3 matrices and tensors. For instance,
  when raw pointers are passed together with dimension initializer list {x,y,z..}. (Although, this can be done by wrapping 
  the data in an Eigen Map object).
  
