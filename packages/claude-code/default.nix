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
    sha256 = "1sqn80dmbfwdczzzmc4bcy0wykl9wyf07gpr7x009hsk3ays5jd0";
  };

  # Claude Code has no dependencies
  # This hash will need to be updated after first build attempt
  # Run: nix build .#claude-code 2>&1 | grep "got:"
  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

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
