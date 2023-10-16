{
  description = "Flexible C Development Environments with LLVM16 and GCC 13";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      createShell = commonPkgs: stdenv: name: pkgs:
        let
          shell = pkgs.mkShell.override { inherit stdenv; };
        in
        shell {
          inherit name;
          packages = with pkgs; commonPkgs;
        };

    in
    {
      devShells = forEachSupportedSystem ({ pkgs }:
        let

          commonPkgs = with pkgs; [
            ccache
            clang-tools_16
            cmake
            cmocka
            meson
            ninja
            pkg-config
            python3
          ] ++ lib.optionals (!stdenv.isDarwin) [
            valgrind
            gdb
            gf
          ];

          gccStdEnv = pkgs.gcc13Stdenv;
          llvmStdEnv = pkgs.llvmPackages_16.stdenv;
          gccMoldStdEnv = pkgs.stdenvAdapters.useMoldLinker gccStdEnv;
          llvmMoldStdEnv = pkgs.stdenvAdapters.useMoldLinker llvmStdEnv;
          gccGoldStdEnv = pkgs.stdenvAdapters.useGoldLinker gccStdEnv;
          llvmGoldStdEnv = pkgs.stdenvAdapters.useGoldLinker llvmStdEnv;

          moldPkgs = with pkgs; [ mold ];
          llvmPkgs = with pkgs; [ llvmPackages_16.lldb llvmPackages_16.llvm llvmPackages_16.bintools ];
        in
        rec
        {
          gcc = createShell commonPkgs gccStdEnv "C Flake with GCC13" pkgs;
          gccMold = createShell (commonPkgs ++ moldPkgs) gccMoldStdEnv "C Flake with GCC13 and Mold" pkgs;
          gccGold = createShell commonPkgs gccGoldStdEnv "C Flake with GCC13 and Gold" pkgs;

          llvm = createShell (commonPkgs ++ llvmPkgs) llvmStdEnv "C Flake with LLVM 16" pkgs;
          llvmMold = createShell (commonPkgs ++ llvmPkgs ++ moldPkgs) llvmMoldStdEnv "C Flake with LLVM 16 and Mold" pkgs;
          llvmGold = createShell (commonPkgs ++ llvmPkgs) llvmGoldStdEnv "C Flake with LLVM 16 and Gold" pkgs;

          default = gcc;
        });
    };
}
