{
  description = "Josh Symonds' nix config";

  inputs = {
    # Nixpkgs - using unstable as primary
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11"; # Keep stable available if needed

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim Nightly
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # Hardware-specific optimizations
    hardware.url = "github:nixos/nixos-hardware/master";

    # Linkpearl - clipboard sync
    linkpearl.url = "github:Veraticus/linkpearl";
  };

  outputs = { nixpkgs, home-manager, self, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      # Only the systems we actually use
      systems = [ "x86_64-linux" ];
      forAllSystems = f: lib.genAttrs systems f;

      # Common special arguments for all configurations
      mkSpecialArgs = system: {
        inherit inputs outputs;
      };
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );

      overlays = import ./overlays { inherit inputs; };

      # NixOS configurations - inlined for clarity
      nixosConfigurations = {
        ultraviolet = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = mkSpecialArgs "x86_64-linux";
          modules = [
            ./hosts/ultraviolet
            ./hosts/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.joshsymonds = import ./home-manager/hosts/ultraviolet.nix;
              home-manager.extraSpecialArgs = mkSpecialArgs "x86_64-linux" // {
                hostname = "ultraviolet";
              };
            }
          ];
        };
        
        bluedesert = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = mkSpecialArgs "x86_64-linux";
          modules = [
            ./hosts/bluedesert
            ./hosts/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.joshsymonds = import ./home-manager/hosts/bluedesert.nix;
              home-manager.extraSpecialArgs = mkSpecialArgs "x86_64-linux" // {
                hostname = "bluedesert";
              };
            }
          ];
        };
        
        echelon = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = mkSpecialArgs "x86_64-linux";
          modules = [
            ./hosts/echelon  # Fixed: was using bluedesert
            ./hosts/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.joshsymonds = import ./home-manager/hosts/echelon.nix;
              home-manager.extraSpecialArgs = mkSpecialArgs "x86_64-linux" // {
                hostname = "echelon";
              };
            }
          ];
        };

        vermissian = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = mkSpecialArgs "x86_64-linux";
          modules = [
            ./hosts/vermissian
            ./hosts/common.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.joshsymonds = import ./home-manager/hosts/vermissian.nix;
              home-manager.extraSpecialArgs = mkSpecialArgs "x86_64-linux" // {
                hostname = "vermissian";
              };
            }
          ];
        };

        trap-top = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = mkSpecialArgs "x86_64-linux";
          modules = [
            ./hosts/trap-top
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.joshsymonds = import ./home-manager/hosts/trap-top.nix;
              home-manager.extraSpecialArgs = mkSpecialArgs "x86_64-linux" // {
                hostname = "trap-top";
              };
            }
          ];
        };
      };

      # Simplified home configurations - generated programmatically
      homeConfigurations = 
        let
          mkHome = { system, module, hostname }: home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ outputs.overlays.default ];
              config.allowUnfree = true;
            };
            extraSpecialArgs = mkSpecialArgs system // { inherit hostname; };
            modules = [ module ];
          };
          
          linuxHosts = [ "ultraviolet" "bluedesert" "echelon" "vermissian" "trap-top" ];
        in
          (lib.genAttrs 
            (map (h: "joshsymonds@${h}") linuxHosts)
            (h: let hostname = lib.removePrefix "joshsymonds@" h; in
              mkHome { 
                system = "x86_64-linux"; 
                module = ./home-manager/hosts/${hostname}.nix; 
                inherit hostname;
              })
          );
    };
}
