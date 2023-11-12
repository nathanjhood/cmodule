# CModule

Multi-platform, multi-architecture C/C++ modules that compile into '\<*\>.node' files, which can be imported as JS modules; for example, to run in the NodeJS runtime environment as NPM packages.

[![Linux](https://github.com/StoneyDSP/cmodule/workflows/linux/badge.svg)](https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Alinux)
[![MacOS](https://github.com/StoneyDSP/cmodule/workflows/macos/badge.svg)](https://github.com/StoneyDSP/cmodule/actions?query=workflow%3macos)
[![Windows](https://github.com/StoneyDSP/cmodule/workflows/windows/badge.svg)](https://github.com/StoneyDSP/cmodule/actions?query=workflow%3Awindows)
[![CMake](https://github.com/StoneyDSP/cmodule/workflows/CMake/badge.svg)](https://github.com/StoneyDSP/cmodule/actions?query=workflow%3CMake)

## Development Requirements:

* NodeJS
* NPM or Yarn
* CMake
* A C/C++ compiler/build toolchain (supports Ninja, GNU, MSVC, CLang...)

## For development of CModules (npm):

```
    npm -g install cmake-js@latest
    // ...will install the required Node API header files for C++ development (only needed once)

    npm install
    // ...will compile the prototype "hello world" cmodule from the files found in 'src/' and 'include/cmodule/'

    npm run test
    // ...will run the built prototype using your system node binary - by default, prints "hello world" to the console and exits

    npm run clean
    // ...will safely remove everything that was just compiled and built in the last few steps, allowing you to continue development

    npm run build
    // ...will rebuild the files found in 'src/' and 'include/cmodule/'... etc
```

## For development of CModules (yarn):

```
    yarn global add cmake-js@latest
    // ...will install the required Node API header files for C++ development (only needed once)

    yarn
    // ...will compile the prototype "hello world" cmodule from the files found in 'src/' and 'include/cmodule/'

    yarn test
    // ...will run the built prototype using your system node binary - by default, prints "hello world" to the console and exits

    yarn clean
    // ...will safely remove everything that was just compiled and built in the last few steps, allowing you to continue development on the project

    yarn rebuild
    // ...will rebuild your development files found in 'src/' and 'include/cmodule/'... etc
```

Your final module can be tested and packaged up using the built-in CTest and CPack commands, respectively, alongside your usual node-based debugging tools. Once packaged, you might publish a release of your module to the npm registry, which can then easily be consumed by using the typical "npm/yarn install" routines.

## A closer look at the development steps of CModules as above, using yarn:

Install the required Node API header files to link with during development (run once only!);

```
    yarn global add cmake-js@latest
```

Running the standard npm/yarn 'install' command from project root folder will compile the current C/C++ source file(s) as part of it's package installation routine;

```
    yarn install
```

Serve the compiled C/C++ files(s) using your system node executable, from the entry point of 'index.js'. Prints 'hello, world!' by default - see the 'cmodule.h/cc' source files to specify the behaviour of your module!

```
    yarn test
```

After tinkering with your project source files, just rebuild them;

```
    yarn rebuild
```

Completely remove all build files, directories, and artefacts... but *does not destroy any header or source files*;

```
    yarn clean
```

The same as the above, but also removes the "node_modules" folder. Useful mostly just before packaging your project for distribution only;

```
    yarn wipe
```

## Where to place your C++ development files for CMake to correctly compile, build, and link them to the output '*.node' file;

We have two project-local directories of key importance in C++ project development;

* the "./src" directory, where 'source' files are kept, and,

* the "./include/<project_name>" directory, where 'header' files are kept

Both specified relative to the project's root folder.

Regarding CMake (which compiles, builds, links etc. the C++ development files into a binary file, using your system's C++ build tools) - the entire configuration is specified in the 'CMakeLists.txt' file in the root folder. Unless you happen to be 'in to' CMake and know it quite well, I'd recommend leaving all of this file very well alone and let it do it's thing, with the *critical* exception of lines 58 - 66, where you should specify a name, version number, homepage, and description for your node module (defaults below - ignore the 'LANGUAGES' field);

``` 
    58  ## Name the project vendor (or intended namespace)
    59  set(PROJECT_VENDOR "StoneyDSP")
    60  ## Create Project
    61  project("cmodule"
    62    VERSION 1.0.0.0
    63    DESCRIPTION "NodeJS module written in C++"
    64    HOMEPAGE_URL "https://github.com/StoneyDSP/cmodule"
    65    LANGUAGES CXX
    66 )
```

*Note* - I will possibly abstract the above CMake interaction away, and have everything defined centrally in the root package.json file. CMake has good tools for parsing JSON with, but I haven't much experience with these just yet. Stay tuned!

The CMake configuration is set to follow the convention that all 'header' files, such as '*.h', '*.hpp' and so forth (usually containing the public-wide 'declarations' of your code), shall live in the "./include/<project_name>" directory, as depicted in the default project files in this repo. CMake will 'glob' *all* files that it finds in this directory, regardless of extension or type, and make these available for the end user(s) by directly copying these files into their project's './node_modules/' tree.

The CMake configuration is also set to follow the convention that all 'source' files, such as '*.cc', '*.cpp' and so forth (usually containing the 'definitions' of your code) shall live in the "./src/" directory, as depicted in the default project files in this repo. Note that CMake will 'glob' *all* files that it finds in this directory, regardless of extension or type. These contents shall be compiled into a binary '*.node' file that only NodeJS can read.

If you stay with the provided paradigm of placing your to-be-linked public header files ('*.h', '*.hpp', etc) in './include/<project_name>', and your to-be-compiled source files ('*.cc', '*.cpp', etc) in './src', then CMake will know what to make your C++ tools do with them, and shouldn't require any further configuration, straight from the box.

This means you can just focus on the C++ and Javascript development files contained therein, and should have a working, multi-platform, multi-arch, multi-OS library for NodeJs straight from the box every time (please see the 'tests' tab of this repo for more info).

## How to publish and consume your C++ package with NodeJS;

Set a valid name and version number in package.json! You should probably change these fields;

```
    "name": "@<team_name>/<project_name>"
    "version": "0.0.1"
```

Replace the team and project names accordingly. Using the "@<team_name>" part of the name entry helps to avoid naming collisions with the rest of the existing npm registry. PLEASE NOTE that once you publish a package under a certain version number, you are able to "unpublish" and remove this package from npm; however, there appears to be no way to ever reclaim the same combination of <package name> with <version number> ever again, even if the package itself has been unpublished and removed from the registry.

To clean the directory before publishing to the npm registry, run;

```
    yarn wipe
```

And to publish it, making it consumable in other npm-based projects publically;

```
    npm publish --access=public
```

Then, you can cd into your existing npm-(or yarn-)based project, or create a new one with the usual "init" command. Assuming this environment meets the system requirements (CMake and a C++ build tool installed), then this simple command;

```
    npm install '@<team_name>/<package_name>'
```

Or if you prefer yarn;

```
    yarn add '@<team_name>/<package_name>'
```

Running one of the above will make your 'cmodule' available in the receiving project's Javascript (and Typescript!) files, via the usual means;

For 'CommonJs'-style syntax;

```
    const <package_name> = require ("@<team_name>/<project_name>");
```

*or*

For 'ES6/Module'-style syntax;

```
    import <package_name> from "@<team_name>/<project_name>";
```

Then, we make an instance of our module;

```
    const myImportedModule = <package_name>;
```

Now you can go ahead and call whatever functions, classes, objects etc you have created in your C++ files, for example;

```
    console.log(myImportedModule.hello());
```

## Example;

Start a new node-based project;

```
    mdkir myProject && cd myProject
    yarn init
```

You can try it out by adding this package to your project the usual way;

```
    yarn add @stoneydsp/cmodule
```

Make an 'index.js', and either 'require' (for CommonJs) or 'import' (for ES6/Module syntax) the module by placing the below code in the javascript file;

```
    const cmodule = require("@stoneydsp/cmodule");

    const myImportedModule = cmodule;

    console.log(myImportedModule.hello());
```

*or*

```
    import * as cmodule from "@stoneydsp/cmodule"

    const myImportedModule = cmodule;

    console.log(myImportedModule.hello());
```

Back on the command line, you can then ask node to execute the file;

```
    node ./index.js
    // hello, world!
```

You can find everything you need to know about using the Node C/C++ Addon API to create your own modules by checking the official docs;

* https://nodejs.org/dist/latest-v19.x/docs/api/n-api.html

* https://github.com/nodejs/node-addon-api

You will also find many excellent examples and tutorials if you know where to look;

* https://github.com/nodejs/node-addon-examples

* https://github.com/cmake-js/cmake-js#tutorials

## Support

Written and tested with windows, linux, and macos ("latest") x64 architectures and a variety of compiler toochains (GNU, MSVC, CLang), as well as cross-compiling via CMake. Able to make use of all the native CMake tools (CMake, CTest, CPack) and full vcpkg integration. Supports "Release", "Debug", "MinSizeRel", and "RelwithDebInfo" build modes (for C++ debugging with, e.g., gdb).

Support for CTest and CPack allows for shipping as C++ and/or CMake modules (via vcpkg in .tar or .zip format), local/global installations as an NPM module, and even packaging as a .deb file.

Please kindly note that the project template is compatible with CMake build pipelines that don't invoke npm/yarn, nor even touch node; however, running a root-folder 'npm/yarn install' command *is* a necessary prerequisite before CMake/CPack/CTest can successfully run. This is because you *need* the 'node_modules' folder with the node-addon-api files in it, as these are actually linked to during the compiler (actually, the linker) process.

## References

I have specified the excellent npm binary package 'bindings' as a dependency, but also investigating possible other more localized approaches to "exporting" the final module. The 'node-addon-api' is probably self-evident in it's inclusion as a package dependency at this moment. CMake-JS does the wonderful work of linking CMake's potentially seamless build process into the generic npm package commands one would typically use everyday in NodeJS development. Thanks to these three dependencies in our project template, and the routines I've defined in CMakeLists.txt, your 'cmodule'-based projects should integrate into a NodeJS workflow with nothing but a little additional time spent waiting for the compiler to finish it's run :)

Your libs will appear in './build/lib', your binaries in './build/bin', and so on (all relative to the project root folder); and by the same convention, your project's header files should *always remain* in './include/<project_name>/', and source files in './src'. These input and output directory paths are *never* mixed, just like an out-of-source build. The C/C++ compiler step will generate several of these new ("dirty") outputs in your root folder ('bin', 'lib', 'share', etc...), and will place these in a directory named 'build/' which your built module is using, specifically at runtime. Aside from during realtime use, these generated directories can *all* be safely removed using the package.json 'clean' script command - or manually, by simply deleting the generated 'build' directory and all it's contents - and your project's sources and header files shall never be over-written, written to, or modified ever, by CMake.

Check out the projects that help make cmodule happen;

* https://github.com/cmake-js/cmake-js

* https://github.com/TooTallNate/node-bindings

* https://github.com/nodejs/node-addon-api

## Thanks for reading!
