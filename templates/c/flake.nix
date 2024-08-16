{
  description = "C Development Environments with LLVM 17 and GCC 14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = f:
      nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (system:
        f {
          pkgs = import nixpkgs {inherit system;};
          pkgsCross = import nixpkgs {
            crossSystem = {config = "x86_64-linux";};
            inherit system;
          };
        });

    mkShell = pkgs: {
      stdenv ? pkgs.stdenv,
      packages ? [],
    }:
      pkgs.mkShell.override {inherit stdenv;} {
        inherit packages;
      };
  in {
    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

    devShells = forAllSystems ({pkgs, ...}: let
      commonPackages = with pkgs;
        [
          ccache
          clang-tools_17
          cmake
          cmocka
          meson
          ninja
          pkg-config
          python3
        ]
        ++ lib.optionals (!stdenv.isDarwin) [
          valgrind
          gdb
          gf
        ];

      llvmPackages = with pkgs.llvmPackages_17; [
        lldb
        llvm
        bintools
      ];

      mkLinkerShell = {
        stdenv,
        packages ? [],
      }:
        mkShell pkgs {
          inherit stdenv;
          packages = commonPackages ++ packages;
        };

      gccStdenv = pkgs.gcc14Stdenv;
      llvmStdenv = pkgs.llvmPackages_17.stdenv;
    in {
      default = mkLinkerShell {stdenv = gccStdenv;};
      gcc = mkLinkerShell {stdenv = gccStdenv;};
      gccMold = mkLinkerShell {
        stdenv = pkgs.stdenvAdapters.useMoldLinker gccStdenv;
        packages = [pkgs.mold];
      };
      gccGold = mkLinkerShell {
        stdenv = pkgs.stdenvAdapters.useGoldLinker gccStdenv;
      };

      llvm = mkLinkerShell {
        stdenv = llvmStdenv;
        packages = llvmPackages;
      };
      llvmMold = mkLinkerShell {
        stdenv = pkgs.stdenvAdapters.useMoldLinker llvmStdenv;
        packages = llvmPackages ++ [pkgs.mold];
      };
      llvmGold = mkLinkerShell {
        stdenv = pkgs.stdenvAdapters.useGoldLinker llvmStdenv;
        packages = llvmPackages;
      };
    });
  };
}
