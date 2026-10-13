{
  description = "Minimal NixOS configuration for the ASUS Zenbook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "danil";
      # Where this repo lives on disk; used by nh and the shell aliases.
      flakeDir = "/etc/nixos";
      theme = import ./theme;
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      checks.${system} =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          files = ./.;
        in
        {
          deadnix = pkgs.runCommand "deadnix-check" { } ''
            ${pkgs.deadnix}/bin/deadnix --no-lambda-arg --no-lambda-pattern-names --fail ${files} >/dev/null
            touch $out
          '';

          statix = pkgs.runCommand "statix-check" { } ''
            cd ${files}
            ${pkgs.statix}/bin/statix check -i hosts/zenbook/hardware.nix -i modules/home/quickshell.nix .
            touch $out
          '';
        };

      nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit theme username flakeDir; };

        modules = [
          ./hosts/zenbook
          home-manager.nixosModules.home-manager
          {
            # Home Manager shares the exact package set used by NixOS.
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = { inherit theme username flakeDir; };
              users.${username} = import ./modules/home;
            };
          }
        ];
      };
    };
}
