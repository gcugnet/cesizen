{
  description = "cesizen";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-z = {
      url = "https://flakehub.com/f/ejpcmac/git-z/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];
      systems = [ "x86_64-linux" ];

      perSystem = { system, ... }:
        let
          overlays = [ (import inputs.rust-overlay) ];
          pkgs = import inputs.nixpkgs {
            inherit system overlays;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };
          };

          rust-toolchain =
            pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

          android-sdk = inputs.android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs;
            [
              cmdline-tools-latest
              build-tools-34-0-0
              ndk-25-2-9519653
              platforms-android-33
              # NOTE: ucnomment lines below to use an emulator.
              # emulator
              # system-images-android-35-google-apis-x86-64
            ]);

          git-z = inputs.git-z.packages.${system}.git-z;
        in
        {
          devshells.default = {
            name = "cesizen";

            motd = ''

              {202}🔨 Welcome to the cesizen devshell!{reset}
              $(type -p menu &>/dev/null && menu)
            '';

            packages = with pkgs; [
              # Build toolchain.
              beam.packages.erlang_26.elixir_1_16
              gcc
              gnumake

              # Project dependencies.
              postgresql_15

              # Development dependencies.
              inotify-tools
              libnotify

              # IDE toolchain.
              nixd
              nixpkgs-fmt

              # Tools.
              flyctl
              git
              gitAndTools.gitflow
              git-z

              # Rust toolchain.
              rust-toolchain
              rust-analyzer

              # Dioxus.
              dioxus-cli
              wasm-bindgen-cli_0_2_100
              nodejs_23 # Needed to start Tailwind watcher
            ];

            env = [
              {
                name = "PGDATA";
                eval = "$PWD/backend/db";
              }

              {
                name = "ANDROID_HOME";
                value = "${android-sdk}/share/android-sdk";
              }

              {
                name = "GRADLE_OPTS";
                value = "-Dorg.gradle.project.android.aapt2FromMavenOverride=" +
                  "${android-sdk}/share/android-sdk/build-tools/34.0.0/aapt2";
              }

              {
                name = "JAVA_HOME";
                value = pkgs.jdk17.home;
              }

              {
                name = "NIX_PATH";
                value = "nixpkgs=${inputs.nixpkgs}";
              }
            ];

            commands = [
              {
                name = "setup";
                help = "Compiles the application, and sets the database up";
                command = builtins.readFile ./scripts/setup;
              }

              {
                name = "start-db";
                help = "Starts a local instance of PostgreSQL";
                command = builtins.readFile ./scripts/start-db;
              }

              {
                name = "stop-db";
                help = "Stops the local instance of PostgreSQL";
                command = builtins.readFile ./scripts/stop-db;
              }

              {
                name = "reset-db";
                help = "Reset the cesizen_dev Postgres database instance";
                command = builtins.readFile ./scripts/reset-db;
              }
            ];
          };
        };
    };
}
