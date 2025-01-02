{ inputs, ... }:
{
  # additions = self: super: import ../pkgs final.pkgs;

  custom =
    _self: super:
    let
      importCustomPackage = pkg: inputs.${pkg}.packages.${super.system}.default;
    in
    {
      matcha = importCustomPackage "matcha";
      pastel = importCustomPackage "pastel";
      agenix = importCustomPackage "agenix";
    };

  modifications = self: super: {
    yambar = super.unstable.yambar.overrideAttrs (oldAttrs: {
      src = oldAttrs.src.override {
        rev = "3e0083c9f21a276840e3487a0a6a85c71e185b4d";
        hash = "sha256-Q+pRFzPuN/uTvQ8XriGrjsj3rogPJPxy3Dx6OzSt2hc=";
      };
    });

    _mullvad-browser = super.mullvad-browser.override {
      extraPrefs = ''
        pref("media.getusermedia.aec_enabled", false);
        pref("media.getusermedia.agc_enabled", false);
        pref("media.getusermedia.noise_enabled", false);
        pref("media.getusermedia.hpf_enabled", false);
        pref("layout.css.devPixelsPerPx", "1.50");
      '';
    };

    mullvad-browser = self._mullvad-browser.overrideAttrs (
      me: _oldAttrs: {
        policiesJson = super.writeText "policies.json" (
          builtins.toJSON {
            policies = {
              DisableAppUpdate = true;
              Extensions.Install = [
                # bitwarden
                # "https://addons.mozilla.org/firefox/downloads/latest/735894/latest.xpi"
                # Proton Pass
                "https://addons.mozilla.org/firefox/downloads/latest/2785662/latest.xpi"
                # kagi
                "https://addons.mozilla.org/firefox/downloads/latest/2749605/latest.xpi"
              ];
              Certificates.ImportEnterpriseRoots = true;
            };
          }
        );
        postInstall = ''
          install -Dvm644 ${me.policiesJson} $out/share/mullvad-browser/distribution/policies.json
        '';
      }
    );
  };

  unstable = self: _super: {
    unstable = import inputs.unstable {
      system = self.system;
      config.allowUnfree = true;
    };
  };
}
