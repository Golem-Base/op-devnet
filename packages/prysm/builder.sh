# shellcheck shell=bash
# shellcheck disable=SC2148,SC1091,SC2154

source "$stdenv"/setup

buildPhase() {
  ./build.sh
}

installPhase() {
  mkdir -p "$out"/{include/elf,include/mach-o,lib,}
  cp libblst.a "$out"/lib/
  cp bindings/*.{h,hpp} "$out"/include/
  cp build/assembly.S "$out"/include/
  cp build/elf/* "$out"/include/elf/
  cp build/mach-o/* "$out"/include/mach-o/
  cp src/*.h "$out"/include/
  cp src/*.c "$out"/include/
}

genericBuild
