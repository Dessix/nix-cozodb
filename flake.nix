{
  description = "CozoDB standalone built with Rust-Nightly";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    cozodb.url = "https://github.com/cozodb/cozo.git?ref=master&rev=fe24ee29870dc4135bbcf57e644f1c4e87ee7fc5";
    cozodb.flake = false;
    cozodb.type = "git";
    cozodb.submodules = true;
  };

  outputs = { self, fenix, flake-utils, nixpkgs, cozodb }:
     (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        defaultPackage = (pkgs.makeRustPlatform {
          inherit (fenix.packages.${system}.minimal) cargo rustc;
        }).buildRustPackage {
          nativeBuildInputs = with pkgs; [
            cmake
          ];
          buildInputs = with pkgs; [
            jemalloc
          ];
          cmakeFlags = pkgs.rocksdb.cmakeFlags;
          env.NIX_CFLAGS_COMPILE = pkgs.rocksdb.NIX_CFLAGS_COMPILE;

          propagatedBuildInputs = with pkgs; [
            bzip2
            lz4
            snappy
            zlib
            zstd
          ];
          pname = "cozo-bin";
          version = "0.7.0";
          src = cozodb;

          cargoLock = {
            lockFile = "${cozodb}/Cargo.lock";
          };

          buildFeatures = [
            "compact"
            "requests"
            "jemalloc"
            "graph-algo"
            "storage-rocksdb"
          ];
        };
      }));
}
