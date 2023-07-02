{
  description = "CozoDB standalone built with Rust-Nightly";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cozodb = {
      type = "git";
      url = "https://github.com/cozodb/cozo.git?ref=master";
      flake = false;
      submodules = true;
    };
  };

  outputs = { self, fenix, flake-utils, nixpkgs, cozodb }:
     (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        toolchain = fenix.packages.${system}.stable.toolchain;
      in
      {
        defaultPackage = (pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        }).buildRustPackage {
          pname = "cozo-bin";
          version = builtins.readFile "${cozodb}/VERSION";
          src = cozodb;

          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = [ pkgs.jemalloc ];
          inherit (pkgs.rocksdb) cmakeFlags NIX_CFLAGS_COMPILE;

          propagatedBuildInputs = with pkgs; [
            bzip2
            lz4
            snappy
            zlib
            zstd
          ];

          cargoLock.lockFile = "${cozodb}/Cargo.lock";

          buildFeatures = [
            "compact"
            "requests"
            "jemalloc"
            "graph-algo"
            "storage-rocksdb"
          ];
          __contentAddressed = true;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
        };
      }));
}
