{
  rustPlatform,
  lib,
  fetchFromGitHub,
  fetchurl,
  autoconf,
  automake,
  libtool,
  pkg-config,
  protobuf,
  cmake,
  git,
  openssl,
  randomx,
  systemd,
}:

rustPlatform.buildRustPackage rec {
  pname = "tari";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "tari-project";
    repo = "tari";
    tag = "v${version}";
    hash = "sha256-A1+xdZwH7JWZfJnkXu4BY4GXuZWY2JnRJnlfHe80ujM=";
  };

  swagger-ui = fetchurl {
    url = "https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip";
    hash = "sha256-SBJE0IEgl7Efuu73n3HZQrFxYX+cn5UU5jrL4T5xzNw=";
  };

  patches = [ ./find-git-root.patch ];

  cargoHash = "sha256-kS1B73l6goBdhWLE5setRC2q6g6xJKgRzHYkrWcxZTc=";

  env = {
    OPENSSL_NO_VENDOR = true;
    SWAGGER_UI_DOWNLOAD_URL = "file://${swagger-ui}";
    RANDOMX_DIR = "${randomx}";

    TARI_NETWORK = "mainnet";
    TARI_TARGET_NETWORK = "mainnet";
  };

  postPatch = ''
    # Don't build vendored randomx
    patch -d $cargoDepsCopy/randomx-rs*/ -p1 < ${./no-vendor-randomx.patch}

    # TODO: patch test itself?
    substituteInPlace integration_tests/build.rs \
      --replace-fail '{out_dir}' "./target/x86_64-unknown-linux-gnu/release/deps/"
  '';

  cargoBuildFlags = [
    "--bin"
    "minotari_node"
    "--bin"
    "minotari_console_wallet"
    "--bin"
    "minotari_miner"
    "--bin"
    "minotari_merge_mining_proxy"
    "--bin"
    "minotari_utils"
  ];

  doCheck = false;
  # useNextest = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    protobuf
    cmake
    git
    randomx
  ];

  buildInputs = [
    openssl
    systemd
    randomx
  ];

  meta = {
    homepage = "https://github.com/tari-project/tari";
    changelog = "https://github.com/tari-project/tari/releases/tag/v${version}";
    description = "The Tari protocol";
    maintainers = [ ];
    mainProgram = "minotari_node";
    platforms = [
      "x86_64-linux"
    ];
    license = lib.licenses.bsd3;
  };
}
