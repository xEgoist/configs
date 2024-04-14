{
  description = "Flexible C Development Environments with LLVM17 and GCC 13";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        pkgsCross = import nixpkgs { crossSystem = { config = "riscv64-none-elf"; }; inherit system; };
      });

      createShell = pkgs: commonPkgs: stdenv: pkgs.mkShell.override { inherit stdenv; } {
        packages = with pkgs; commonPkgs;
      };

    in
    {
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixpkgs-fmt);
      devShells = forAllSystems ({ pkgs, pkgsCross }:
        let

          commonPkgs = with pkgs; [
            ccache
            clang-tools_17
            cmake
            cmocka
            # dtc  # for RISC-V DEV
            meson
            ninja
            pkg-config
            # pkgsCross.stdenv.cc # for RISC-V DEV
            python3
          ] ++ lib.optionals (!stdenv.isDarwin) [
            valgrind
            gdb
            gf
          ];
          moldPkgs = with pkgs; [ mold ];
          llvmPkgs = with pkgs; [ llvmPackages_17.lldb llvmPackages_17.llvm llvmPackages_17.bintools ];

          gccStdEnv = pkgs.gcc13Stdenv;
          llvmStdEnv = pkgs.llvmPackages_17.stdenv;
          gccMoldStdEnv = pkgs.stdenvAdapters.useMoldLinker gccStdEnv;
          llvmMoldStdEnv = pkgs.stdenvAdapters.useMoldLinker llvmStdEnv;
          gccGoldStdEnv = pkgs.stdenvAdapters.useGoldLinker gccStdEnv;
          llvmGoldStdEnv = pkgs.stdenvAdapters.useGoldLinker llvmStdEnv;

        in
        rec
        {
          gcc = createShell pkgs commonPkgs gccStdEnv;
          gccMold = createShell pkgs (commonPkgs ++ moldPkgs) gccMoldStdEnv;
          gccGold = createShell pkgs commonPkgs gccGoldStdEnv;

          llvm = createShell pkgs (commonPkgs ++ llvmPkgs) llvmStdEnv;
          llvmMold = createShell pkgs (commonPkgs ++ llvmPkgs ++ moldPkgs) llvmMoldStdEnv;
          llvmGold = createShell pkgs (commonPkgs ++ llvmPkgs) llvmGoldStdEnv;

          default = gcc;
        });
    };
}
