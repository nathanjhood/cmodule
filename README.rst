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
----------------------------------

* npm -g install cmake-js@latest
* npm install
* npm test
* npm clean


For development of CModules (yarn):
-----------------------------------

* yarn global add cmake-js@latest
* yarn
* yarn test
* yarn clean


Your final module can be tested and packaged up using the built-in CTest and CPack commands, respectively, alongside your usual node-based debugging tools. Once packaged, you might publish a release of your module using GitHub Packages, which can then easily be consumed by using the typical "npm/yarn add yourmodule" routines.

A closer look at the development steps of CModules as above, using yarn:

..  code-block:: shell
    :caption: example
    
    yarn global add cmake-js@latest

    # Run standard yarn command from project root folder to compile the current C/C++ source file(s)
    yarn install

    # Serve the compiled C/C++ files(s) using your system node executable, from the entry point of 'index.js'
    yarn test 

    # The above prints 'hello, world!' by default - see the 'cmodule.h/cc' source files to specify the behaviour of your module!
    # After tinkering with your project source files, just rebuild them:
    yarn rebuild

    # Completely remove all build files, directories, and artefacts... does not destroy any source files :)
    yarn wipe


Supports "Release", "Debug", "MinSizeRel", and "RelwithDebInfo" build modes (for C++ debugging with, e.g., gdb).

Supports CTest and CPack, for shipping as C++ and/or CMake modules (via vcpkg in .tar or .zip format), local/global installations as an NPM module, and even packaging as a .deb file.

Please kindly note that the project template is compatible with CMake build pipelines that don't invoke npm/yarn, nor even touch node; however, running a root-folder 'npm/yarn install' command *is* a necessary prerequisite before CMake/CPack/CTest can successfully run. This is because you *need* the 'node_modules' folder with the node-addon-api files in it, as these are actually linked to during the compiler (actually, the linker) process.

I have specified the excellent npm binary package 'bindings' as a dependency, but also included a slightly modified and fully credited copy in the 'support' folder. The reason is, 'bindings' is hard-wired to regex-match a cetain set of search criteria, looking for files with a '.node' extension inside certain directories. I've currently targeted a kind-of mixed approach between 'in-source' and 'out-of-source' builds, wherein we have specified more than one generated output directory (to match the architecture of a typical npm package). 

Your libs will appear in './lib', your binaries in './bin' and so on (all relative to the project root folder); and by the same convention, your project's header files should *always remain* in './include/<project_name>/', and source files in './src'. These input and output paths are *never* mixed, just like an out-of-source build. The C/C++ compiler step will generate several of these new ("dirty") outputs in your root folder ('bin', 'lib', 'share', etc...), which your built module is using, specifically at runtime. Aside from during realtime use, these generated directories can *all* be safely removed using the package.json 'clean' script command - or manually - and your project's sources and header files shall never be over-written, written to, or modified ever, by CMake. 

Since node has issues running symlinks with long and unusual extensions ('cmodule.node.1.0.0.0', for example, doesn't fly), it is crucial that 'bindings.js' is searching in the correct places for our compiled '.node' file(s) - namely, they will appear in those safely-destructible './bin' and './lib' directories, which is where they typically *would* be for an npm module, of course. Thus, for now, I've modified the included 'bindings.js' to point at these output directories, so it succesfully locates your outputted <project>.node file(s). This is a sore-point as we do not wish to be packaging other developers' code in un-intended ways into our template codebase. Our most likely solution is to rake CMake *even further* over the coals - perhaps just by copying the builds back into the './build' directory :p who knows? But this will be fixed imminently.

Thanks for reading!
