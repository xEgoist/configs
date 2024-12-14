{ inputs, ... }:
{
  # additions = self: super: import ../pkgs final.pkgs;

  custom = _self: super: {
    matcha = inputs.matcha.packages.${super.system}.default;
    pastel = inputs.pastel.packages.${super.system}.default;
  };

  modifications = self: super: {
    yambar = super.unstable.yambar.overrideAttrs (oldAttrs: {
      src = oldAttrs.src.override {
        rev = "3e0083c9f21a276840e3487a0a6a85c71e185b4d";
        hash = "sha256-Q+pRFzPuN/uTvQ8XriGrjsj3rogPJPxy3Dx6OzSt2hc=";
      };
    });
  };

  unstable = self: _super: {
    unstable = import inputs.unstable {
      system = self.system;
      config.allowUnfree = true;
    };
  };
}
