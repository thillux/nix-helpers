```shell
nix-prefetch-url https://linux.mellanox.com/public/repo/bluefield/4.10.0-13520/bootimages/prod/mlxbf-bootimages-signed_4.10.0-13520_arm64.deb | xargs nix hash convert --hash-algo sha256
```

```shell
nix hash convert --hash-algo sha256 --from sri --to nix32 sha256-XrrM9Mo0KM0mgXuuYhcfTv0nDu2Gaj49Ch2elwt7dSk=
```

```shell
NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix develop --builders '' -v .#cuda --impure
```
