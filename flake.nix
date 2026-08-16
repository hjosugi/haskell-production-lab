{
  description = "Haskell development environment for haskell-production-lab";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # GHC 9.8.4 is what .github/workflows/ci.yml installs and what
      # tested-with names first, so the shell tracks that instead of whatever
      # nixpkgs happens to default to. haskell-language-server and fourmolu
      # come from the same package set: HLS has to be built against the
      # compiler it is asked to load a project with.
      haskell = pkgs.haskell.packages.ghc984;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          haskell.ghc
          haskell.haskell-language-server
          haskell.fourmolu

          # cabal-install is compiler-independent, so the top-level package is
          # fine and keeps it off the ghc984 rebuild path.
          pkgs.cabal-install
          pkgs.pkg-config
        ];

        # postgresql-simple builds against libpq, and cabal.project asks
        # postgresql-libpq to locate it with pkg-config rather than by guessing
        # a prefix. These are buildInputs so their dev outputs reach
        # PKG_CONFIG_PATH; the postgresql package also brings psql and initdb
        # along for running the integration test against a local server.
        #
        # openssl and curl are here because pkg-config resolves the whole
        # dependency chain, not just the top entry: libpq.pc declares
        # `Requires.private: libssl, libcrypto, libcurl`, and without their .pc
        # files the configure step fails with "Package 'libssl', required by
        # 'libpq', not found" before anything is compiled.
        buildInputs = [
          pkgs.postgresql
          pkgs.openssl
          pkgs.curl
          pkgs.zlib
        ];
      };
    };
}
