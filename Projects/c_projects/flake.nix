{
  description = "A Flexible C Development Environment with LLVM16 and GCC 13";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let

      # ---- MAIN SWITCHES ----

      useLLVM = true;
      useMold = true;
      useGold = false;

      # ----               ----

      # mkShell = (pkgs.mkShell.override { stdenv = pkgs.pkgsCross.mingwW64.stdenv; });

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }:
        assert pkgs.lib.assertMsg (!(useMold && useGold))
          "useMold and useGold cannot be enabled at the same time.";
        let

          # Used for setting meson's linker environment variables (CC_LD/CXX_LD)
          linker = (if useMold then "mold" else if useLLVM then "lld" else if useGold then "gold" else "ld");

          # Sets mkShell to the corrosponding stdenv so the compiler works correctly.
          # If Mold/Gold is enabled, use the adapter so it it sets fuse-ld as part of the compilation.
          mkShell =
            if useLLVM then
              (pkgs.mkShell.override {
                stdenv =
                  if useMold then
                    pkgs.stdenvAdapters.useMoldLinker pkgs.llvmPackages_16.stdenv
                  else if useGold then
                    pkgs.stdenvAdapters.useGoldLinker pkgs.llvmPackages_16.stdenv
                  else
                    pkgs.llvmPackages_16.stdenv;
              })
            else
              (pkgs.mkShell.override {
                stdenv =
                  if useMold then
                    pkgs.stdenvAdapters.useMoldLinker pkgs.gcc13Stdenv
                  else if useGold then
                    pkgs.stdenvAdapters.useGoldLinker pkgs.gcc13Stdenv
                  else
                    pkgs.gcc13Stdenv;
              })
          ;
        in
        {
          default = mkShell {
            name = "C Flake";
            packages = with pkgs;

              lib.optionals (useLLVM)
                [
                  llvmPackages_16.lldb
                  llvmPackages_16.llvm
                  llvmPackages_16.bintools
                ]
              ++
              lib.optionals (useMold) [ mold ] ++
              [
                gdb
                ccache
                clang-tools_16
                cmocka
                cmake
                # fmt
                gf
                meson
                ninja
                pkg-config
                valgrind
                # For Cross Compilation
                # pkgsCross.mingwW64.stdenv.cc
                # pkgsCross.mingwW64.windows.pthreads
              ];

            # For meson build system
            CC_LD = linker;
            CXX_LD = linker;

          };
        });
    };
}
