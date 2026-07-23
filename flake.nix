{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs@{ self, nixpkgs, darwin, stylix, nvf }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        # Desktop apps
        ghostty-bin
        jetbrains.webstorm
        # CLI
        claude-code
        git
        gh
        lazygit
        stow
        fastfetch
        zoxide
        eza
        bat
        fzf
        fd
        btop
        yazi
        mc
        p7zip
        ffmpeg
        yt-dlp
        podman
        devenv
        # Fonts
        nerd-fonts.jetbrains-mono
      ];

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.nvf = {
        enable = true;
        settings = {
          vim = {
            viAlias = true;
            vimAlias = true;
            syntaxHighlighting = true;
            options = {
              # tab settings
              tabstop = 2;
              shiftwidth = 2;
              softtabstop = 2;
              expandtab = true;
              shiftround = true;
              autoindent = true;
              smartindent = true;

              number = true;
              relativenumber = true;
              cursorline = true;
            };
            formatter = {
              conform-nvim.enable = true;
            };
            visuals = {
              indent-blankline = {
                enable = true;
                setupOpts = {
                  indent = {
                    char = "▏";
                    tab_char = "▏";
                  };
                  scope = {
                    enabled = true;
                    show_start = true;
                    show_end = false;
                  };
                };
              };
            };
            statusline.lualine = {
              enable = true;
            };
            ui = {
              ui2.enable = true;
            };
            languages = {
              enableFormat = true;
              enableTreesitter = true;
              docker.enable = true;
              env.enable = true;
              json.enable = true;
              markdown.enable = true;
              nix.enable = true;
              yaml.enable = true;
              zsh.enable = true;
            };
            lsp = {
              enable = true;
            };
          };
        };
      };

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      };

      environment.shellAliases = {
        "lg" = "lazygit";
        "e" = "nvim";
        ".." = "cd ..";
        "..." = "cd ../..";
        "ls" = "eza --icons=auto --git --group --time-style=long-iso";
        "l" = "ls --long";
        "ll" = "l -a";
        "switch" = "sudo darwin-rebuild switch";
        "update" = "sudo nix flake update --flake /etc/nix-darwin";
      };

      environment.variables = {
        EDITOR = "nvim";
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      # nix-darwin will be upset when this is true
      nix.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      nixpkgs.config.allowUnfree = true;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#studio
    darwinConfigurations."studio" = darwin.lib.darwinSystem {
      modules = [
        nvf.darwinModules.default
        stylix.darwinModules.stylix
        configuration
      ];
    };
    darwinConfigurations."air" = darwin.lib.darwinSystem {
      modules = [
        nvf.darwinModules.default
        stylix.darwinModules.stylix
        configuration
      ];
    };
  };
}
