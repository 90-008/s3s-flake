`s3s` packaged in Nix flakes. Add the package onto your system to make it available everywhere. Alternatively use `nix run github:yusdacra/s3s-flake -- -r` to run it without having to add it.

### Module

This flake also includes a module that can be used with `home-manager` if you use it.

Simply add the output `homeManagerModule` to your `imports` for your user and set `services.s3s.enable = true`. You will also want to run `s3s` at least once in `~/.config/s3s/` so that the `config.txt` is generated there (or if you already have a config file just copy it there). This path is configurable in the module options, so you can change it if you really need to. The service will run every 5 minutes by default via a timer, this can also be changed.
