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
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will need to be updated
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will need to be updated

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
