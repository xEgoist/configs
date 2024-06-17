with import <nixpkgs> {};
  mkShell {
    name = "Zig Shell";
    buildInputs = with pkgs; [
      cmake
      gdb
      python39
      libxml2
      zstd
      valgrind
      ninja
      qemu
      wasmtime
      zlib
    ];
  }
