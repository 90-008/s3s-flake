{
  config,
  lib,
  dream2nix,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  name = "s3s";

  mkDerivation = {
    buildPhase = ''
      patch s3s.py -i ${./pwd.patch}
      echo "#!${config.deps.stdenv.shell}" >> s3s
      echo "echo \$PWD" >> s3s
      echo "${config.public.pyEnv}/bin/python $out/lib/s3s/s3s.py \$@" >> s3s
      chmod +x s3s
    '';
    installPhase = ''
      mkdir -p $out/{bin,lib/s3s}
      cp iksm.py utils.py s3s.py $out/lib/s3s
      cp s3s $out/bin
    '';
  };

  buildPythonPackage = {
    format = "other";
  };

  pip = {
    requirementsList = lib.splitString "\n" (builtins.readFile "${config.mkDerivation.src}/requirements.txt");
    flattenDependencies = true;
  };
}
