# clipper-luajit-ffi
LuaJIT FFI bindings for the C++ version of [Angus Johnson's Clipper library](https://sourceforge.net/projects/polyclipping/).

## Pre-built binaries
Pre-built binaries can be found in the [releases page](https://github.com/apicici/clipper-luajit-ffi/releases) for the following systems/architectures:
* Linux x64
* Windows x86, x64
* macos x64

## Compilation
The shared library required for LuaJIT FFI can be compiled using CMake with the provided `CMakeLists.txt`.

## Usage
### C++ library
Refer to the [Clipper library's documentation](http://www.angusj.com/delphi/clipper/documentation/Docs/_Body.htm) for usage of the C++ library.

### LuaJIT bindings
1. Place the shared library (`clipper.so`, `clipper.dll`, or `clipper.dylib`, depending on the system) and `clipper.lua` somewhere where they can be found by ```require```. You may need to modify ```package.path``` and ```package.cpath```.
2. Require the library with
	```lua
	local clipper = require "clipper"
	```
#### Notes
* Lua numbers are automatically converted to Clipper's ```CInt``` type. However, ```CInt``` cdata objects are not automatically converted to numbers (use ```tonumber``` to convert them).
* FFI does not use explicit pointers or references. Just pass an object to a function, and it will be treated as a value, pointer, or reference as necessary
* Clipper ```Path``` and ```Paths``` are wrapped in Lua and (mostly) behave as ```std::vector```. Usage examples:
  ```lua
  path = clipper.Path() -- initialise empty vector
  path.push_back(clipper.IntPoint(1,2)) -- add IntPoint to vector
  
  path = clipper.Path(3) -- initialise vector of size 3
  path[0] = clipper.IntPoint(2, 3) -- specify first IntPoint in vector
  ```
