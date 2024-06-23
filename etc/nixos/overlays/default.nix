{inputs, ...}: {
  # additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable = final: _prev: {
    unstable = import inputs.unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
