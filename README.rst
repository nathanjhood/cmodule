CModule
-------

Multi-platform, multi-architecture C/C++ modules that compile into '<*>.node' files, which can be imported as JS modules, for example to run in the NodeJS runtime environment as NPM packages.

.. image:: https://github.com/StoneyDSP/cmodule/workflows/linux/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Alinux

.. image:: https://github.com/StoneyDSP/cmodule/workflows/macos/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3macos

.. image:: https://github.com/StoneyDSP/cmodule/workflows/windows/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Awindows

.. image:: https://github.com/StoneyDSP/cmodule/workflows/CMake/badge.svg
   :target: https://github.com/StoneyDSP/cmodule/actions?query=workflow%3CMake


Development Requirements:
-------------

* NodeJS
* NPM or Yarn
* CMake
* A C/C++ compiler

For development of CModules (npm):
----------------------------------
.. code::

    npm -g install cmake-js@latest
    // ...will install the required Node API header files for C++ development 
    
    npm install 
    // ...will compile the prototype "hello world" cmodule from the files found in 'src/' and 'include/cmodule/'
    
    npm run test 
    // ...will run the built prototype using your system node binary - by default, prints "hello world" to the console and exits
    
    npm run clean 
    // ...will safely remove everything that was just compiled and built in the last few steps, allowing you to continue development
    
    npm run build
    // ...will rebuild the files found in 'src/' and 'include/cmodule/'... etc


For development of CModules (yarn):
-----------------------------------
.. code::

    yarn global add cmake-js@latest
    // ...will install the required Node API header files for C++ development
    
    yarn
    // ...will compile the prototype "hello world" cmodule from the files found in 'src/' and 'include/cmodule/'
    
    yarn test
    // ...will run the built prototype using your system node binary - by default, prints "hello world" to the console and exits
    
    yarn clean
    // ...will safely remove everything that was just compiled and built in the last few steps, allowing you to continue development on the project
    
    yarn build
    // ...will rebuild the files found in 'src/' and 'include/cmodule/'... etc

Your final module can be tested and packaged up using the built-in CTest and CPack commands, respectively, alongside your usual node-based debugging tools. Once packaged, you might publish a release of your module using GitHub Packages, which can then easily be consumed by using the typical "npm/yarn add yourmodule" routines.

A closer look at the development steps of CModules as above, using yarn:
------------------------------------------------------------------------
.. code::
    
    yarn global add cmake-js@latest

...installs the required Node API header files to link with during development

.. code::

    yarn install

...the standard npm/yarn 'install' command from project root folder will compile the current C/C++ source file(s) as part of it's package installation routine

.. code:: 
    
    yarn test

...serves the compiled C/C++ files(s) using your system node executable, from the entry point of 'index.js'. Prints 'hello, world!' by default - see the 'cmodule.h/cc' source files to specify the behaviour of your module!

.. code::

    yarn rebuild

After tinkering with your project source files, just rebuild them!

.. code::
    
    yarn clean

This completely remove all build files, directories, and artefacts... but does not destroy any source files :)

.. code::
    
    yarn wipe

The same as the above, but also removes the "node_modules" folder. Useful mostly just before packaging your project for distribution only.

Where to place your C++ development files for CMake to correctly compile, build, and link them to the output '*.node' file;
---------------------------------------------------------------------------------------------------------------------------

We have two project-local directories of key importance in C++ project development; the "./src" directory, and "./include/<project_name>" directory - both specified from the project's root folder.

Regarding CMake (which compiles, builds, links etc. the C++ development files into a binary file, using your system's C++ build tools) - the entire configuration is specified in the 'CMakeLists.txt' file in the root folder. Unless you happen to be 'in to' CMake and know it quite well, I'd recommend leaving all of this file well alone, with the exception of lines 116 - 122, where you can specify a name, version number, homepage, and description for your node module (defaults below);
.. code::
    
    116 ## Create Project
    117 project("cmodule"
    118   VERSION 1.0.0.0
    119   DESCRIPTION "NodeJS module written in C++"
    120   HOMEPAGE_URL "https://github.com/StoneyDSP/cmodule"
    121   LANGUAGES CXX
    122 )

The CMake configuration is set to follow the convention that all 'header' files, such as '*.h', '*.hpp' and so forth (usually containing the public-wide 'declarations' of your code), shall live in the "./include/<project_name>" directory, as depicted in the default project files in this repo.

The CMake configuration is also set to follow the convention that all 'source' files, such as '*.cc', '*.cpp' and so forth (usually containing the 'definitions' of your code - note that the contents of this folder shall be compiled into a binary '*.node' file that only NodeJS can read), shall live in the "./src/" directory, as depicted in the default project files in this repo.

If you stay with the provided paradigm of placing your to-be-linked public header files ('*.h', '*.hpp', etc) in './include/<project_name>', and your to-be-compiled source files ('*.cc', '*.cpp', etc) in './src', then CMake will know what to make your C++ tools do with them, and shouldn't require any further configuration, straight from the box.


How to publish and consume your C++ package for NodeJS;
-------------------------------------------------------
* Set a valid name and version number in package.json!
You should probably change these fields to;
.. code::
    
    "name": "@<team_name>/<project_name>"
    "version": "0.0.1"

Replacing the team and project names accordingly. Using the "@<team_name>" part of the name entry helps to avoid naming collisions with the rest of the existing npm registry. PLEASE NOTE that once you publish a package under a certain version number, you are able to "unpublish" and remove this package from npm; however, there appears to be no way to ever reclaim the same combination of <package name> with <version number> ever again, even if the package itself has been unpublished and removed from the registry.

.. code::
    
    yarn wipe

To clean the directory before publishing to the npm registry

.. code::
    
    npm publish --access=public

Then, you can cd into your existing npm-(or yarn-)based project, or create a new one with the usual "init" command. Assuming this environment meets the system requirements (CMake and a C++ build tool installed), then this simple command;

.. code::

    npm install '@<team_name>/<package_name>'

Or if you prefer yarn;

.. code::

    yarn add '@<team_name>/<package_name>'

Running one of the above will make your 'cmodule' available in the receiving project's Javascript (and Typescript!) files, via the usual means;

.. code::

    const <package_name> = require ("@<team_name>/<project_name>");

For 'CommonJs'-style syntax, or;

.. code::

    import <package_name> from "@<team_name>/<project_name>";

For 'ES6/Module'-style syntax.

Then, we make an instance of our module;
.. code:: 
    
    const myImportedModule = <package_name>;

Now you can go ahead and call whatever functions, classes, objects etc you have created in your C++ files, for example;
.. code::
    
    console.log(myImportedModule.hello());

Support
-------

Written and tested with windows, linux, and macos ("latest") x64 architectures and a variety of compiler toochains (GNU, MSVC, CLang), as well as cross-compiling via CMake. Able to make use of all the native CMake tools (CMake, CTest, CPack) and full vcpkg integration. Supports "Release", "Debug", "MinSizeRel", and "RelwithDebInfo" build modes (for C++ debugging with, e.g., gdb).

Support for CTest and CPack allows for shipping as C++ and/or CMake modules (via vcpkg in .tar or .zip format), local/global installations as an NPM module, and even packaging as a .deb file.

Please kindly note that the project template is compatible with CMake build pipelines that don't invoke npm/yarn, nor even touch node; however, running a root-folder 'npm/yarn install' command *is* a necessary prerequisite before CMake/CPack/CTest can successfully run. This is because you *need* the 'node_modules' folder with the node-addon-api files in it, as these are actually linked to during the compiler (actually, the linker) process.

References
----------
I have specified the excellent npm binary package 'bindings' as a dependency, but also investigating possible other more localized approaches to "exporting" the final module. The 'node-addon-api' is probably self-evident in it's inclusion as a package dependency at this moment.

Your libs will appear in './lib', your binaries in './bin' and so on (all relative to the project root folder); and by the same convention, your project's header files should *always remain* in './include/<project_name>/', and source files in './src'. These input and output paths are *never* mixed, just like an out-of-source build. The C/C++ compiler step will generate several of these new ("dirty") outputs in your root folder ('bin', 'lib', 'share', etc...), and will place these in a directory named 'build' which your built module is using, specifically at runtime. Aside from during realtime use, these generated directories can *all* be safely removed using the package.json 'clean' script command - or manually - and your project's sources and header files shall never be over-written, written to, or modified ever, by CMake. 

Since node has issues running symlinks with long and unusual extensions ('cmodule.node.1.0.0.0', for example, doesn't fly), it is crucial that 'bindings.js' is searching in the correct places for our compiled '.node' file(s) - namely, they will appear in those safely-destructible './bin' and './lib' directories, which is where they typically *would* be for an npm module, of course. Thus, for now, I've modified the included 'bindings.js' to point at these output directories, so it succesfully locates your outputted <project>.node file(s). This is a sore-point as we do not wish to be packaging other developers' code in un-intended ways into our template codebase. Our most likely solution is to rake CMake *even further* over the coals - perhaps just by copying the builds back into the './build' directory :p who knows? But this will be fixed imminently.

Thanks for reading!
-------------------
