{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "opencode";
  version = "0.0.55";

  src = fetchFromGitHub {
    owner = "opencode-ai";
    repo = "opencode";
    rev = "v${version}";
    sha256 = "03696q34mfwmgbdqis1rpzdlq4z2qfpqppzq3wqmag9ax6sqscaj";
  };

  # Vendor hash will need to be updated after first build attempt
  # Run: nix build .#opencode 2>&1 | grep "got:"
  vendorHash = "sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # OpenCode requires Go 1.24+
  # Tests may require network access for Ollama
  doCheck = false;

  meta = with lib; {
    description = "AI coding assistant for the terminal using local Ollama models";
    homepage = "https://github.com/opencode-ai/opencode";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "opencode";
    platforms = platforms.unix;
  };
}
