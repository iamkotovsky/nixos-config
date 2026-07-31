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
      theme = import ./theme;
    in
    {
      nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit theme; };

        modules = [
          ./hosts/zenbook
          home-manager.nixosModules.home-manager
          {
            # Home Manager shares the exact package set used by NixOS.
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit theme; };
            home-manager.users.danil = import ./modules/home;
          }
        ];
      };
    };
}
