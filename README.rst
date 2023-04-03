CModule
-------

Multi-platform, multi-architecture C/C++ modules that compile into '<*>.node' files, which can be imported as JS modules, for example to run in the NodeJS runtime environment as NPM packages.

.. image:: https://github.com/StoneyDSP/cmodule/workflows/linux/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Alinux

.. image:: https://github.com/StoneyDSP/cmodule/workflows/macos/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3macos

.. image:: https://github.com/StoneyDSP/cmodule/workflows/windows/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Awindows


Requirements:
-------------

* NodeJS
* NPM or Yarn
* CMake
* A C/C++ compiler

For development of CModules (npm):

```
npm -g install cmake-js@latest
# cd into root folder
npm install
```

For development of CModules (yarn):

```
yarn global add cmake-js@latest
# cd into root folder
yarn install
```

Supports "Release", "Debug", "MinSizeRel", and "RelwithDebInfo" build modes (for C++ debugging with, e.g., gdb).

Supports CTest and CPack, for shipping as C++ and/or CMake modules (via vcpkg in .tar or .zip format), and local/global installations as an NPM module.
