{ lib
, buildNpmPackage
, fetchurl
, nodejs
}:

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.1.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will need to be updated with: nix-prefetch-url <url>
  };

  # Claude Code has no dependencies (empty package-lock.json)
  npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Official CLI for Claude AI coding assistant by Anthropic";
    homepage = "https://www.anthropic.com/claude";
    license = licenses.unfree; # Proprietary
    maintainers = [ ];
    mainProgram = "claude";
    platforms = platforms.all;
  };
}
