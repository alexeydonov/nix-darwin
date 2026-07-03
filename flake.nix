{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [
          pkgs.neovim
          pkgs.git
          pkgs.gh
          pkgs.lazygit
          pkgs.stow
          pkgs.fastfetch
          pkgs.zoxide
          pkgs.eza
          pkgs.bat
          pkgs.fzf
          pkgs.fd
          pkgs.btop
          pkgs.yazi
          pkgs.mc
          pkgs.p7zip
          pkgs.ffmpeg
          pkgs.yt-dlp
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.podman
        ];

      environment.shellAliases =
      {
        "lg" = "lazygit";
        "e" = "nvim";
        ".." = "cd ..";
        "..." = "cd ...";
        "ls" = "eza --icons=auto --git --group --time-style=long-iso";
        "l" = "ls --long";
        "ll" = "l -a";
        "rebuild" = "sudo darwin-rebuild switch";
      };

      environment.variables =
      {
        EDITOR = "nvim";
      };

      # nix-darwin will be upset when this is true
      nix.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#studio
    darwinConfigurations."studio" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
