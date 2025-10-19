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
      systems = [ "x86_64-linux" "aarch64-darwin" ];

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
          devshells =
            let
              buildToolchain = with pkgs; [
                beam.packages.erlang_26.elixir_1_16
                gcc
                gnumake
                rust-toolchain
              ];

              projectDependencies = with pkgs; [
                # Postgres
                postgresql_15

                # Dioxus
                dioxus-cli
                wasm-bindgen-cli_0_2_100
                nodejs_23
              ];

              deploymentDependencies = with pkgs; [
                flyctl
              ];

              ideToolchain = with pkgs; [
                nixd
                nixpkgs-fmt
                rust-analyzer

              ];

              developmentTools = with pkgs; [
                inotify-tools
                libnotify
                git
                gitAndTools.gitflow
                git-z
              ];

              buildEnv = [
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
              ];

              ideEnv = [
                {
                  name = "NIX_PATH";
                  value = "nixpkgs=${inputs.nixpkgs}";
                }
              ];

            in

            {
              default = {

                name = "cesizen";

                motd = ''

                  {202}🔨 Welcome to the cesizen devshell!{reset}
                  $(type -p menu &>/dev/null && menu)
                '';

                packages = buildToolchain
                  ++ projectDependencies
                  ++ deploymentDependencies
                  ++ ideToolchain
                  ++ developmentTools;

                env = buildEnv
                  ++ ideEnv;

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

                  {
                    name = "start-tailwind";
                    help = "Starts the Tailwind watcher";
                    command = builtins.readFile ./scripts/start-tailwind;
                  }
                ];
              };

              ci = {
                name = "cesizen CI";

                packages = buildToolchain
                  ++ projectDependencies;

                env = buildEnv;

                commands = [
                  {
                    name = "test-backend";
                    help = "Get dependencies, compiles the application, sets the database and run backend tests";
                    command = builtins.readFile ./scripts/test-backend;
                  }

                  {
                    name = "test-frontend";
                    help = "Get dependencies, creates tailwind.css, compiles the application, and run frontend tests";
                    command = builtins.readFile ./scripts/test-frontend;
                  }
                ];
              };
            };
        };
    };
}
