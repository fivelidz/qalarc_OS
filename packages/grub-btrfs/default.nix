{ lib
, stdenv
, fetchFromGitHub
, bash
, btrfs-progs
, gawk
, gnugrep
, coreutils
, gnused
, util-linux
, grub2
, inotify-tools
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "grub-btrfs";
  version = "4.14";

  src = fetchFromGitHub {
    owner = "Antynea";
    repo = "grub-btrfs";
    rev = "v${version}";
    sha256 = "sha256-WtMwL5F3c8wx09RIuGYQ80FVMznKW8ppNUqOEP3YLbE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    btrfs-progs
    gawk
    gnugrep
    coreutils
    gnused
    util-linux
    grub2
    inotify-tools
  ];

  # Don't use the Makefile - it expects FHS paths
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the main script
    install -Dm755 41_snapshots-btrfs $out/etc/grub.d/41_snapshots-btrfs

    # Install the daemon
    install -Dm755 grub-btrfsd $out/bin/grub-btrfsd

    # Install config
    install -Dm644 config $out/etc/default/grub-btrfs/config

    # Install man pages
    install -Dm644 manpages/grub-btrfs.8.man $out/share/man/man8/grub-btrfs.8
    install -Dm644 manpages/grub-btrfsd.8.man $out/share/man/man8/grub-btrfsd.8

    # Install systemd service
    install -Dm644 grub-btrfsd.service $out/lib/systemd/system/grub-btrfsd.service

    # Wrap scripts with runtime dependencies
    wrapProgram $out/etc/grub.d/41_snapshots-btrfs \
      --prefix PATH : ${lib.makeBinPath [
        bash btrfs-progs gawk gnugrep coreutils gnused util-linux grub2
      ]}

    wrapProgram $out/bin/grub-btrfsd \
      --prefix PATH : ${lib.makeBinPath [
        bash btrfs-progs gawk gnugrep coreutils gnused util-linux grub2 inotify-tools
      ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Include btrfs snapshots in GRUB boot options";
    homepage = "https://github.com/Antynea/grub-btrfs";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
