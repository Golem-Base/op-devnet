# shellcheck shell=bash
# shellcheck disable=SC2148,SC1091,SC2154

source "$stdenv"/setup

buildPhase() {
  ./build.sh
}

installPhase() {
  mkdir -p "$out"/{include/elf,lib}
  cp libblst.a "$out"/lib/
  cp bindings/*.{h,hpp} "$out"/include/
  cp build/assembly.S "$out"/include/
  cp build/elf/* "$out"/include/elf/
  cp src/*.h "$out"/include/
  cp src/*.c "$out"/include/
}

genericBuild
