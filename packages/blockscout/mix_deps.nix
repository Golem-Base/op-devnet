{
  lib,
  beamPackages,
  overrides ? (_x: _y: {}),
}: let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages;
  with self; {
    absinthe = buildMix rec {
      name = "absinthe";
      version = "1.7.9";

      src = fetchHex {
        pkg = "absinthe";
        version = "${version}";
        sha256 = "08ae6339b05252b98e859ccd76614c94325c991f85aa325edde30027b7b044fc";
      };

      beamDeps = [dataloader decimal nimble_parsec telemetry];
    };

    absinthe_phoenix = buildMix rec {
      name = "absinthe_phoenix";
      version = "2.0.3";

      src = fetchHex {
        pkg = "absinthe_phoenix";
        version = "${version}";
        sha256 = "caffaea03c17ea7419fe07e4bc04c2399c47f0d8736900623dbf4749a826fd2c";
      };

      beamDeps = [absinthe absinthe_plug decimal phoenix phoenix_html phoenix_pubsub];
    };

    absinthe_relay = buildMix rec {
      name = "absinthe_relay";
      version = "1.5.2";

      src = fetchHex {
        pkg = "absinthe_relay";
        version = "${version}";
        sha256 = "0587ee913afa31512e1457a5064ee88427f8fe7bcfbeeecd41c71d9cff0b62b6";
      };

      beamDeps = [absinthe ecto];
    };

    accept = buildRebar3 rec {
      name = "accept";
      version = "0.3.6";

      src = fetchHex {
        pkg = "accept";
        version = "${version}";
        sha256 = "a5167fa1ae90315c3f1dd189446312f8a55d00efa357e9c569bda47736b874c3";
      };

      beamDeps = [];
    };

    bamboo = buildMix rec {
      name = "bamboo";
      version = "2.3.1";

      src = fetchHex {
        pkg = "bamboo";
        version = "${version}";
        sha256 = "895b2993ed195b2b0fa79c0d5a1d36aa529e817b6df257e4a10745459048d505";
      };

      beamDeps = [hackney jason mime plug];
    };

    bcrypt_elixir = buildMix rec {
      name = "bcrypt_elixir";
      version = "3.2.1";

      src = fetchHex {
        pkg = "bcrypt_elixir";
        version = "${version}";
        sha256 = "81170177d5c2e280d12141a0b9d9e299bf731535e2d959982bdcd4cfe3c82865";
      };

      beamDeps = [comeonin elixir_make];
    };

    benchee = buildMix rec {
      name = "benchee";
      version = "1.3.1";

      src = fetchHex {
        pkg = "benchee";
        version = "${version}";
        sha256 = "76224c58ea1d0391c8309a8ecbfe27d71062878f59bd41a390266bf4ac1cc56d";
      };

      beamDeps = [deep_merge statistex];
    };

    benchee_csv = buildMix rec {
      name = "benchee_csv";
      version = "1.0.0";

      src = fetchHex {
        pkg = "benchee_csv";
        version = "${version}";
        sha256 = "cdefb804c021dcf7a99199492026584be9b5a21d6644ac0d01c81c5d97c520d5";
      };

      beamDeps = [benchee csv];
    };

    blake2 = buildMix rec {
      name = "blake2";
      version = "1.0.4";

      src = fetchHex {
        pkg = "blake2";
        version = "${version}";
        sha256 = "e9f4120d163ba14d86304195e50745fa18483e6ad2be94c864ae449bbdd6a189";
      };

      beamDeps = [];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "1.0.0";

      src = fetchHex {
        pkg = "bunt";
        version = "${version}";
        sha256 = "dc5f86aa08a5f6fa6b8096f0735c4e76d54ae5c9fa2c143e5a1fc7c1cd9bb6b5";
      };

      beamDeps = [];
    };

    bureaucrat = buildMix rec {
      name = "bureaucrat";
      version = "0.2.10";

      src = fetchHex {
        pkg = "bureaucrat";
        version = "${version}";
        sha256 = "bc7e5162b911c29c8ebefee87a2c16fbf13821a58f448a8fd024eb6c17fae15c";
      };

      beamDeps = [inflex phoenix plug poison];
    };

    bypass = buildMix rec {
      name = "bypass";
      version = "2.1.0";

      src = fetchHex {
        pkg = "bypass";
        version = "${version}";
        sha256 = "d9b5df8fa5b7a6efa08384e9bbecfe4ce61c77d28a4282f79e02f1ef78d96b80";
      };

      beamDeps = [plug plug_cowboy ranch];
    };

    cachex = buildMix rec {
      name = "cachex";
      version = "4.0.3";

      src = fetchHex {
        pkg = "cachex";
        version = "${version}";
        sha256 = "d5d632da7f162f8a190f1c39b712c0ebc9cf0007c4e2029d44eddc8041b52d55";
      };

      beamDeps = [eternal ex_hash_ring jumper sleeplocks unsafe];
    };

    castore = buildMix rec {
      name = "castore";
      version = "1.0.12";

      src = fetchHex {
        pkg = "castore";
        version = "${version}";
        sha256 = "3dca286b2186055ba0c9449b4e95b97bf1b57b47c1f2644555879e659960c224";
      };

      beamDeps = [];
    };

    cbor = buildMix rec {
      name = "cbor";
      version = "1.0.1";

      src = fetchHex {
        pkg = "cbor";
        version = "${version}";
        sha256 = "5431acbe7a7908f17f6a9cd43311002836a34a8ab01876918d8cfb709cd8b6a2";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.14.0";

      src = fetchHex {
        pkg = "certifi";
        version = "${version}";
        sha256 = "ea59d87ef89da429b8e905264fdec3419f84f2215bb3d81e07a18aac919026c3";
      };

      beamDeps = [];
    };

    cldr_utils = buildMix rec {
      name = "cldr_utils";
      version = "2.28.2";

      src = fetchHex {
        pkg = "cldr_utils";
        version = "${version}";
        sha256 = "c506eb1a170ba7cdca59b304ba02a56795ed119856662f6b1a420af80ec42551";
      };

      beamDeps = [castore certifi decimal];
    };

    cloak = buildMix rec {
      name = "cloak";
      version = "1.1.4";

      src = fetchHex {
        pkg = "cloak";
        version = "${version}";
        sha256 = "92b20527b9aba3d939fab0dd32ce592ff86361547cfdc87d74edce6f980eb3d7";
      };

      beamDeps = [jason];
    };

    cloak_ecto = buildMix rec {
      name = "cloak_ecto";
      version = "1.3.0";

      src = fetchHex {
        pkg = "cloak_ecto";
        version = "${version}";
        sha256 = "314beb0c123b8a800418ca1d51065b27ba3b15f085977e65c0f7b2adab2de1cc";
      };

      beamDeps = [cloak ecto];
    };

    combine = buildMix rec {
      name = "combine";
      version = "0.10.0";

      src = fetchHex {
        pkg = "combine";
        version = "${version}";
        sha256 = "1b1dbc1790073076580d0d1d64e42eae2366583e7aecd455d1215b0d16f2451b";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.5.1";

      src = fetchHex {
        pkg = "comeonin";
        version = "${version}";
        sha256 = "65aac8f19938145377cee73973f192c5645873dcf550a8a6b18187d17c13ccdb";
      };

      beamDeps = [];
    };

    con_cache = buildMix rec {
      name = "con_cache";
      version = "1.1.1";

      src = fetchHex {
        pkg = "con_cache";
        version = "${version}";
        sha256 = "1def4d1bec296564c75b5bbc60a19f2b5649d81bfa345a2febcc6ae380e8ae15";
      };

      beamDeps = [telemetry];
    };

    cors_plug = buildMix rec {
      name = "cors_plug";
      version = "3.0.3";

      src = fetchHex {
        pkg = "cors_plug";
        version = "${version}";
        sha256 = "3f2d759e8c272ed3835fab2ef11b46bddab8c1ab9528167bd463b6452edf830d";
      };

      beamDeps = [plug];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.13.0";

      src = fetchHex {
        pkg = "cowboy";
        version = "${version}";
        sha256 = "e724d3a70995025d654c1992c7b11dbfea95205c047d86ff9bf1cda92ddc5614";
      };

      beamDeps = [cowlib ranch];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.4.0";

      src = fetchHex {
        pkg = "cowboy_telemetry";
        version = "${version}";
        sha256 = "7d98bac1ee4565d31b62d59f8823dfd8356a169e7fcbb83831b8a5397404c9de";
      };

      beamDeps = [cowboy telemetry];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.14.0";

      src = fetchHex {
        pkg = "cowlib";
        version = "${version}";
        sha256 = "0af652d1550c8411c3b58eed7a035a7fb088c0b86aff6bc504b0bc3b7f791aa2";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.7.11";

      src = fetchHex {
        pkg = "credo";
        version = "${version}";
        sha256 = "56826b4306843253a66e47ae45e98e7d284ee1f95d53d1612bb483f88a8cf219";
      };

      beamDeps = [bunt file_system jason];
    };

    csv = buildMix rec {
      name = "csv";
      version = "2.5.0";

      src = fetchHex {
        pkg = "csv";
        version = "${version}";
        sha256 = "e821f541487045c7591a1963eeb42afff0dfa99bdcdbeb3410795a2f59c77d34";
      };

      beamDeps = [parallel_stream];
    };

    dataloader = buildMix rec {
      name = "dataloader";
      version = "2.0.2";

      src = fetchHex {
        pkg = "dataloader";
        version = "${version}";
        sha256 = "4c6cabc0b55e96e7de74d14bf37f4a5786f0ab69aa06764a1f39dda40079b098";
      };

      beamDeps = [ecto telemetry];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.7.0";

      src = fetchHex {
        pkg = "db_connection";
        version = "${version}";
        sha256 = "dcf08f31b2701f857dfc787fbad78223d61a32204f217f15e881dd93e4bdd3ff";
      };

      beamDeps = [telemetry];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.3.0";

      src = fetchHex {
        pkg = "decimal";
        version = "${version}";
        sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
      };

      beamDeps = [];
    };

    decorator = buildMix rec {
      name = "decorator";
      version = "1.4.0";

      src = fetchHex {
        pkg = "decorator";
        version = "${version}";
        sha256 = "0a07cedd9083da875c7418dea95b78361197cf2bf3211d743f6f7ce39656597f";
      };

      beamDeps = [];
    };

    deep_merge = buildMix rec {
      name = "deep_merge";
      version = "1.0.0";

      src = fetchHex {
        pkg = "deep_merge";
        version = "${version}";
        sha256 = "ce708e5f094b9cd4e8f2be4f00d2f4250c4095be93f8cd6d018c753894885430";
      };

      beamDeps = [];
    };

    deps_nix = buildMix rec {
      name = "deps_nix";
      version = "2.2.0";

      src = fetchHex {
        pkg = "deps_nix";
        version = "${version}";
        sha256 = "cc302e2b3edc51dc658b32552f3bbef276f722f78936ac923b38fa60f899f645";
      };

      beamDeps = [mint];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.4.5";

      src = fetchHex {
        pkg = "dialyxir";
        version = "${version}";
        sha256 = "b0fb08bb8107c750db5c0b324fa2df5ceaa0f9307690ee3c1f6ba5b9eb5d35c3";
      };

      beamDeps = [erlex];
    };

    digital_token = buildMix rec {
      name = "digital_token";
      version = "1.0.0";

      src = fetchHex {
        pkg = "digital_token";
        version = "${version}";
        sha256 = "8ed6f5a8c2fa7b07147b9963db506a1b4c7475d9afca6492136535b064c9e9e6";
      };

      beamDeps = [cldr_utils jason];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.44";

      src = fetchHex {
        pkg = "earmark_parser";
        version = "${version}";
        sha256 = "4778ac752b4701a5599215f7030989c989ffdc4f6df457c5f36938cc2d2a2750";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.12.5";

      src = fetchHex {
        pkg = "ecto";
        version = "${version}";
        sha256 = "6eb18e80bef8bb57e17f5a7f068a1719fbda384d40fc37acb8eb8aeca493b6ea";
      };

      beamDeps = [decimal jason telemetry];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.12.1";

      src = fetchHex {
        pkg = "ecto_sql";
        version = "${version}";
        sha256 = "aff5b958a899762c5f09028c847569f7dfb9cc9d63bdb8133bff8a5546de6bf5";
      };

      beamDeps = [db_connection ecto postgrex telemetry];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.9.0";

      src = fetchHex {
        pkg = "elixir_make";
        version = "${version}";
        sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
      };

      beamDeps = [];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.7";

      src = fetchHex {
        pkg = "erlex";
        version = "${version}";
        sha256 = "3ed95f79d1a844c3f6bf0cea61e0d5612a42ce56da9c03f01df538685365efb0";
      };

      beamDeps = [];
    };

    eternal = buildMix rec {
      name = "eternal";
      version = "1.2.2";

      src = fetchHex {
        pkg = "eternal";
        version = "${version}";
        sha256 = "2c9fe32b9c3726703ba5e1d43a1d255a4f3f2d8f8f9bc19f094c7cb1a7a9e782";
      };

      beamDeps = [];
    };

    ex_abi = buildMix rec {
      name = "ex_abi";
      version = "0.8.3";

      src = fetchHex {
        pkg = "ex_abi";
        version = "${version}";
        sha256 = "6349a10331c54a1e09865811f705913fa181bc75b4c9a2d326fd96e21bf60cd4";
      };

      beamDeps = [ex_keccak];
    };

    ex_aws = buildMix rec {
      name = "ex_aws";
      version = "2.5.8";

      src = fetchHex {
        pkg = "ex_aws";
        version = "${version}";
        sha256 = "8f79777b7932168956c8cc3a6db41f5783aa816eb50de356aed3165a71e5f8c3";
      };

      beamDeps = [hackney jason jsx mime sweet_xml telemetry];
    };

    ex_aws_s3 = buildMix rec {
      name = "ex_aws_s3";
      version = "2.5.6";

      src = fetchHex {
        pkg = "ex_aws_s3";
        version = "${version}";
        sha256 = "9874e12847e469ca2f13a5689be04e546c16f63caf6380870b7f25bf7cb98875";
      };

      beamDeps = [ex_aws sweet_xml];
    };

    ex_brotli = buildMix rec {
      name = "ex_brotli";
      version = "0.5.0";

      src = fetchHex {
        pkg = "ex_brotli";
        version = "${version}";
        sha256 = "8447d98d51f8f312629fd38619d4f564507dcf3a03d175c3f8f4ddf98e46dd92";
      };

      beamDeps = [phoenix rustler_precompiled];
    };

    ex_cldr = buildMix rec {
      name = "ex_cldr";
      version = "2.41.0";

      src = fetchHex {
        pkg = "ex_cldr";
        version = "${version}";
        sha256 = "9efc801ceed935120ca9d3d76cfe80d03abe00b9bca65400ec89d24bae53847d";
      };

      beamDeps = [cldr_utils decimal gettext jason nimble_parsec];
    };

    ex_cldr_currencies = buildMix rec {
      name = "ex_cldr_currencies";
      version = "2.16.4";

      src = fetchHex {
        pkg = "ex_cldr_currencies";
        version = "${version}";
        sha256 = "46a67d1387f14e836b1a24d831fa5f0904663b4f386420736f40a7d534e3cb9e";
      };

      beamDeps = [ex_cldr jason];
    };

    ex_cldr_lists = buildMix rec {
      name = "ex_cldr_lists";
      version = "2.11.1";

      src = fetchHex {
        pkg = "ex_cldr_lists";
        version = "${version}";
        sha256 = "00161c04510ccb3f18b19a6b8562e50c21f1e9c15b8ff4c934bea5aad0b4ade2";
      };

      beamDeps = [ex_cldr_numbers ex_doc jason];
    };

    ex_cldr_numbers = buildMix rec {
      name = "ex_cldr_numbers";
      version = "2.34.0";

      src = fetchHex {
        pkg = "ex_cldr_numbers";
        version = "${version}";
        sha256 = "37d9f66f3a3d6675715e95b59b91d40301d233894d41b8bb7e3a11ac6d24ba02";
      };

      beamDeps = [decimal digital_token ex_cldr ex_cldr_currencies jason];
    };

    ex_cldr_units = buildMix rec {
      name = "ex_cldr_units";
      version = "3.18.0";

      src = fetchHex {
        pkg = "ex_cldr_units";
        version = "${version}";
        sha256 = "b9526723b9beb4528a28ddc9ce5e4df95044652cfc9161f99ef8e4edc8c898f8";
      };

      beamDeps = [cldr_utils decimal ex_cldr_lists ex_cldr_numbers ex_doc jason];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.37.3";

      src = fetchHex {
        pkg = "ex_doc";
        version = "${version}";
        sha256 = "e6aebca7156e7c29b5da4daa17f6361205b2ae5f26e5c7d8ca0d3f7e18972233";
      };

      beamDeps = [earmark_parser makeup_elixir makeup_erlang];
    };

    ex_hash_ring = buildMix rec {
      name = "ex_hash_ring";
      version = "6.0.4";

      src = fetchHex {
        pkg = "ex_hash_ring";
        version = "${version}";
        sha256 = "89adabf31f7d3dfaa36802ce598ce918e9b5b33bae8909ac1a4d052e1e567d18";
      };

      beamDeps = [];
    };

    ex_json_schema = buildMix rec {
      name = "ex_json_schema";
      version = "0.10.2";

      src = fetchHex {
        pkg = "ex_json_schema";
        version = "${version}";
        sha256 = "37f43be60f8407659d4d0155a7e45e7f406dab1f827051d3d35858a709baf6a6";
      };

      beamDeps = [decimal];
    };

    ex_keccak = buildMix rec {
      name = "ex_keccak";
      version = "0.7.6";

      src = fetchHex {
        pkg = "ex_keccak";
        version = "${version}";
        sha256 = "9d1568424eb7b995e480d1b7f0c1e914226ee625496600abb922bba6f5cdc5e4";
      };

      beamDeps = [rustler_precompiled];
    };

    ex_machina = buildMix rec {
      name = "ex_machina";
      version = "2.8.0";

      src = fetchHex {
        pkg = "ex_machina";
        version = "${version}";
        sha256 = "79fe1a9c64c0c1c1fab6c4fa5d871682cb90de5885320c187d117004627a7729";
      };

      beamDeps = [ecto ecto_sql];
    };

    ex_rlp = buildMix rec {
      name = "ex_rlp";
      version = "0.6.0";

      src = fetchHex {
        pkg = "ex_rlp";
        version = "${version}";
        sha256 = "7135db93b861d9e76821039b60b00a6a22d2c4e751bf8c444bffe7a042f1abaf";
      };

      beamDeps = [];
    };

    ex_secp256k1 = buildMix rec {
      name = "ex_secp256k1";
      version = "0.7.4";

      src = fetchHex {
        pkg = "ex_secp256k1";
        version = "${version}";
        sha256 = "465fd788c83c24d2df47f302e8fb1011054c81a905345e377c957b159a783bfc";
      };

      beamDeps = [rustler_precompiled];
    };

    ex_utils = buildMix rec {
      name = "ex_utils";
      version = "0.1.7";

      src = fetchHex {
        pkg = "ex_utils";
        version = "${version}";
        sha256 = "66d4fe75285948f2d1e69c2a5ddd651c398c813574f8d36a9eef11dc20356ef6";
      };

      beamDeps = [];
    };

    exjsx = buildMix rec {
      name = "exjsx";
      version = "4.0.0";

      src = fetchHex {
        pkg = "exjsx";
        version = "${version}";
        sha256 = "32e95820a97cffea67830e91514a2ad53b888850442d6d395f53a1ac60c82e07";
      };

      beamDeps = [jsx];
    };

    expo = buildMix rec {
      name = "expo";
      version = "1.1.0";

      src = fetchHex {
        pkg = "expo";
        version = "${version}";
        sha256 = "fbadf93f4700fb44c331362177bdca9eeb8097e8b0ef525c9cc501cb9917c960";
      };

      beamDeps = [];
    };

    exvcr = buildMix rec {
      name = "exvcr";
      version = "0.16.0";

      src = fetchHex {
        pkg = "exvcr";
        version = "${version}";
        sha256 = "8f576af22369942f7a1482baff1f31e2f45983cf6fac45d49d2bd2e84b4d5be8";
      };

      beamDeps = [exjsx httpoison meck];
    };

    file_info = buildMix rec {
      name = "file_info";
      version = "0.0.4";

      src = fetchHex {
        pkg = "file_info";
        version = "${version}";
        sha256 = "50e7ad01c2c8b9339010675fe4dc4a113b8d6ca7eddce24d1d74fd0e762781a5";
      };

      beamDeps = [mimetype_parser];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "1.1.0";

      src = fetchHex {
        pkg = "file_system";
        version = "${version}";
        sha256 = "bfcf81244f416871f2a2e15c1b515287faa5db9c6bcf290222206d120b3d43f6";
      };

      beamDeps = [];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.37.0";

      src = fetchHex {
        pkg = "floki";
        version = "${version}";
        sha256 = "516a0c15a69f78c47dc8e0b9b3724b29608aa6619379f91b1ffa47109b5d0dd3";
      };

      beamDeps = [];
    };

    flow = buildMix rec {
      name = "flow";
      version = "1.2.4";

      src = fetchHex {
        pkg = "flow";
        version = "${version}";
        sha256 = "874adde96368e71870f3510b91e35bc31652291858c86c0e75359cbdd35eb211";
      };

      beamDeps = [gen_stage];
    };

    gen_stage = buildMix rec {
      name = "gen_stage";
      version = "1.2.1";

      src = fetchHex {
        pkg = "gen_stage";
        version = "${version}";
        sha256 = "83e8be657fa05b992ffa6ac1e3af6d57aa50aace8f691fcf696ff02f8335b001";
      };

      beamDeps = [];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.26.2";

      src = fetchHex {
        pkg = "gettext";
        version = "${version}";
        sha256 = "aa978504bcf76511efdc22d580ba08e2279caab1066b76bb9aa81c4a1e0a32a5";
      };

      beamDeps = [expo];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.23.0";

      src = fetchHex {
        pkg = "hackney";
        version = "${version}";
        sha256 = "6cd1c04cd15c81e5a493f167b226a15f0938a84fc8f0736ebe4ddcab65c0b44e";
      };

      beamDeps = [certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat];
    };

    hammer = buildMix rec {
      name = "hammer";
      version = "6.2.1";

      src = fetchHex {
        pkg = "hammer";
        version = "${version}";
        sha256 = "b9476d0c13883d2dc0cc72e786bac6ac28911fba7cc2e04b70ce6a6d9c4b2bdc";
      };

      beamDeps = [poolboy];
    };

    hammer_backend_redis = buildMix rec {
      name = "hammer_backend_redis";
      version = "6.2.0";

      src = fetchHex {
        pkg = "hammer_backend_redis";
        version = "${version}";
        sha256 = "9965d55705d7ca7412bb0685f5cd44fc47d103bf388abc50438e71974c36c9fa";
      };

      beamDeps = [hammer redix];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "1.0.2";

      src = fetchHex {
        pkg = "hpax";
        version = "${version}";
        sha256 = "2f09b4c1074e0abd846747329eaa26d535be0eb3d189fa69d812bfb8bfefd32f";
      };

      beamDeps = [];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "2.2.2";

      src = fetchHex {
        pkg = "httpoison";
        version = "${version}";
        sha256 = "de7ac49fe2ffd89219972fdf39b268582f6f7f68d8cd29b4482dacca1ce82324";
      };

      beamDeps = [hackney];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "idna";
        version = "${version}";
        sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
      };

      beamDeps = [unicode_util_compat];
    };

    inflex = buildMix rec {
      name = "inflex";
      version = "2.1.0";

      src = fetchHex {
        pkg = "inflex";
        version = "${version}";
        sha256 = "14c17d05db4ee9b6d319b0bff1bdf22aa389a25398d1952c7a0b5f3d93162dd8";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.4";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
      };

      beamDeps = [decimal];
    };

    joken = buildMix rec {
      name = "joken";
      version = "2.6.2";

      src = fetchHex {
        pkg = "joken";
        version = "${version}";
        sha256 = "5134b5b0a6e37494e46dbf9e4dad53808e5e787904b7c73972651b51cce3d72b";
      };

      beamDeps = [jose];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.10";

      src = fetchHex {
        pkg = "jose";
        version = "${version}";
        sha256 = "0d6cd36ff8ba174db29148fc112b5842186b68a90ce9fc2b3ec3afe76593e614";
      };

      beamDeps = [];
    };

    jsx = buildMix rec {
      name = "jsx";
      version = "2.8.3";

      src = fetchHex {
        pkg = "jsx";
        version = "${version}";
        sha256 = "fc3499fed7a726995aa659143a248534adc754ebd16ccd437cd93b649a95091f";
      };

      beamDeps = [];
    };

    jumper = buildMix rec {
      name = "jumper";
      version = "1.0.2";

      src = fetchHex {
        pkg = "jumper";
        version = "${version}";
        sha256 = "9b7782409021e01ab3c08270e26f36eb62976a38c1aa64b2eaf6348422f165e1";
      };

      beamDeps = [];
    };

    junit_formatter = buildMix rec {
      name = "junit_formatter";
      version = "3.4.0";

      src = fetchHex {
        pkg = "junit_formatter";
        version = "${version}";
        sha256 = "bb36e2ae83f1ced6ab931c4ce51dd3dbef1ef61bb4932412e173b0cfa259dacd";
      };

      beamDeps = [];
    };

    logger_file_backend = buildMix rec {
      name = "logger_file_backend";
      version = "0.0.14";

      src = fetchHex {
        pkg = "logger_file_backend";
        version = "${version}";
        sha256 = "071354a18196468f3904ef09413af20971d55164267427f6257b52cfba03f9e6";
      };

      beamDeps = [];
    };

    logger_json = buildMix rec {
      name = "logger_json";
      version = "5.1.4";

      src = fetchHex {
        pkg = "logger_json";
        version = "${version}";
        sha256 = "3f20eea58e406a33d3eb7814c7dff5accb503bab2ee8601e84da02976fa3934c";
      };

      beamDeps = [ecto jason phoenix plug telemetry];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.2.1";

      src = fetchHex {
        pkg = "makeup";
        version = "${version}";
        sha256 = "d36484867b0bae0fea568d10131197a4c2e47056a6fbe84922bf6ba71c8d17ce";
      };

      beamDeps = [nimble_parsec];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "1.0.1";

      src = fetchHex {
        pkg = "makeup_elixir";
        version = "${version}";
        sha256 = "7284900d412a3e5cfd97fdaed4f5ed389b8f2b4cb49efc0eb3bd10e2febf9507";
      };

      beamDeps = [makeup nimble_parsec];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "1.0.2";

      src = fetchHex {
        pkg = "makeup_erlang";
        version = "${version}";
        sha256 = "af33ff7ef368d5893e4a267933e7744e46ce3cf1f61e2dccf53a111ed3aa3727";
      };

      beamDeps = [makeup];
    };

    math = buildMix rec {
      name = "math";
      version = "0.7.0";

      src = fetchHex {
        pkg = "math";
        version = "${version}";
        sha256 = "7987af97a0c6b58ad9db43eb5252a49fc1dfe1f6d98f17da9282e297f594ebc2";
      };

      beamDeps = [];
    };

    meck = buildRebar3 rec {
      name = "meck";
      version = "0.9.2";

      src = fetchHex {
        pkg = "meck";
        version = "${version}";
        sha256 = "81344f561357dc40a8344afa53767c32669153355b626ea9fcbc8da6b3045826";
      };

      beamDeps = [];
    };

    memento = buildMix rec {
      name = "memento";
      version = "0.3.2";

      src = fetchHex {
        pkg = "memento";
        version = "${version}";
        sha256 = "25cf691a98a0cb70262f4a7543c04bab24648cb2041d937eb64154a8d6f8012b";
      };

      beamDeps = [];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "metrics";
        version = "${version}";
        sha256 = "69b09adddc4f74a40716ae54d140f93beb0fb8978d8636eaded0c31b6f099f16";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.6";

      src = fetchHex {
        pkg = "mime";
        version = "${version}";
        sha256 = "c9945363a6b26d747389aac3643f8e0e09d30499a138ad64fe8fd1d13d9b153e";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.3.0";

      src = fetchHex {
        pkg = "mimerl";
        version = "${version}";
        sha256 = "a1e15a50d1887217de95f0b9b0793e32853f7c258a5cd227650889b38839fe9d";
      };

      beamDeps = [];
    };

    mimetype_parser = buildMix rec {
      name = "mimetype_parser";
      version = "0.1.3";

      src = fetchHex {
        pkg = "mimetype_parser";
        version = "${version}";
        sha256 = "7d8f80c567807ce78cd93c938e7f4b0a20b1aaaaab914bf286f68457d9f7a852";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.7.1";

      src = fetchHex {
        pkg = "mint";
        version = "${version}";
        sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
      };

      beamDeps = [castore hpax];
    };

    mock = buildMix rec {
      name = "mock";
      version = "0.3.9";

      src = fetchHex {
        pkg = "mock";
        version = "${version}";
        sha256 = "9e1b244c4ca2551bb17bb8415eed89e40ee1308e0fbaed0a4fdfe3ec8a4adbd3";
      };

      beamDeps = [meck];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.2.0";

      src = fetchHex {
        pkg = "mox";
        version = "${version}";
        sha256 = "c7b92b3cc69ee24a7eeeaf944cd7be22013c52fcb580c1f33f50845ec821089a";
      };

      beamDeps = [nimble_ownership];
    };

    msgpax = buildMix rec {
      name = "msgpax";
      version = "2.4.0";

      src = fetchHex {
        pkg = "msgpax";
        version = "${version}";
        sha256 = "ca933891b0e7075701a17507c61642bf6e0407bb244040d5d0a58597a06369d2";
      };

      beamDeps = [plug];
    };

    nimble_csv = buildMix rec {
      name = "nimble_csv";
      version = "1.2.0";

      src = fetchHex {
        pkg = "nimble_csv";
        version = "${version}";
        sha256 = "d0628117fcc2148178b034044c55359b26966c6eaa8e2ce15777be3bbc91b12a";
      };

      beamDeps = [];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "1.1.1";

      src = fetchHex {
        pkg = "nimble_options";
        version = "${version}";
        sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
      };

      beamDeps = [];
    };

    nimble_ownership = buildMix rec {
      name = "nimble_ownership";
      version = "1.0.1";

      src = fetchHex {
        pkg = "nimble_ownership";
        version = "${version}";
        sha256 = "3825e461025464f519f3f3e4a1f9b68c47dc151369611629ad08b636b73bb22d";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.4.2";

      src = fetchHex {
        pkg = "nimble_parsec";
        version = "${version}";
        sha256 = "4b21398942dda052b403bbe1da991ccd03a053668d147d53fb8c4e0efe09c973";
      };

      beamDeps = [];
    };

    number = buildMix rec {
      name = "number";
      version = "1.0.5";

      src = fetchHex {
        pkg = "number";
        version = "${version}";
        sha256 = "c0733a0a90773a66582b9e92a3f01290987f395c972cb7d685f51dd927cd5169";
      };

      beamDeps = [decimal];
    };

    oauth2 = buildMix rec {
      name = "oauth2";
      version = "2.1.0";

      src = fetchHex {
        pkg = "oauth2";
        version = "${version}";
        sha256 = "8ac07f85b3307dd1acfeb0ec852f64161b22f57d0ce0c15e616a1dfc8ebe2b41";
      };

      beamDeps = [tesla];
    };

    optimal = buildMix rec {
      name = "optimal";
      version = "0.3.6";

      src = fetchHex {
        pkg = "optimal";
        version = "${version}";
        sha256 = "1a06ea6a653120226b35b283a1cd10039550f2c566edcdec22b29316d73640fd";
      };

      beamDeps = [];
    };

    parallel_stream = buildMix rec {
      name = "parallel_stream";
      version = "1.1.0";

      src = fetchHex {
        pkg = "parallel_stream";
        version = "${version}";
        sha256 = "684fd19191aedfaf387bbabbeb8ff3c752f0220c8112eb907d797f4592d6e871";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.4.1";

      src = fetchHex {
        pkg = "parse_trans";
        version = "${version}";
        sha256 = "620a406ce75dada827b82e453c19cf06776be266f5a67cff34e1ef2cbb60e49a";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.5.14";

      src = fetchHex {
        pkg = "phoenix";
        version = "${version}";
        sha256 = "207f1aa5520320cbb7940d7ff2dde2342162cf513875848f88249ea0ba02fef7";
      };

      beamDeps = [jason phoenix_html phoenix_pubsub plug plug_cowboy plug_crypto telemetry];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.6.3";

      src = fetchHex {
        pkg = "phoenix_ecto";
        version = "${version}";
        sha256 = "909502956916a657a197f94cc1206d9a65247538de8a5e186f7537c895d95764";
      };

      beamDeps = [ecto phoenix_html plug postgrex];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "3.3.4";

      src = fetchHex {
        pkg = "phoenix_html";
        version = "${version}";
        sha256 = "0249d3abec3714aff3415e7ee3d9786cb325be3151e6c4b3021502c585bf53fb";
      };

      beamDeps = [plug];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.5.3";

      src = fetchHex {
        pkg = "phoenix_live_reload";
        version = "${version}";
        sha256 = "b4ec9cd73cb01ff1bd1cac92e045d13e7030330b74164297d1aee3907b54803c";
      };

      beamDeps = [file_system phoenix];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.17.7";

      src = fetchHex {
        pkg = "phoenix_live_view";
        version = "${version}";
        sha256 = "25eaf41028eb351b90d4f69671874643a09944098fefd0d01d442f40a6091b6f";
      };

      beamDeps = [jason phoenix phoenix_html telemetry];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.3";

      src = fetchHex {
        pkg = "phoenix_pubsub";
        version = "${version}";
        sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
      };

      beamDeps = [];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.17.0";

      src = fetchHex {
        pkg = "plug";
        version = "${version}";
        sha256 = "f6692046652a69a00a5a21d0b7e11fcf401064839d59d6b8787f23af55b1e6bc";
      };

      beamDeps = [mime plug_crypto telemetry];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.7.3";

      src = fetchHex {
        pkg = "plug_cowboy";
        version = "${version}";
        sha256 = "77c95524b2aa5364b247fa17089029e73b951ebc1adeef429361eab0bb55819d";
      };

      beamDeps = [cowboy cowboy_telemetry plug];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.5";

      src = fetchHex {
        pkg = "plug_crypto";
        version = "${version}";
        sha256 = "26549a1d6345e2172eb1c233866756ae44a9609bd33ee6f99147ab3fd87fd842";
      };

      beamDeps = [];
    };

    poison = buildMix rec {
      name = "poison";
      version = "4.0.1";

      src = fetchHex {
        pkg = "poison";
        version = "${version}";
        sha256 = "ba8836feea4b394bb718a161fc59a288fe0109b5006d6bdf97b6badfcf6f0f25";
      };

      beamDeps = [];
    };

    poolboy = buildRebar3 rec {
      name = "poolboy";
      version = "1.5.2";

      src = fetchHex {
        pkg = "poolboy";
        version = "${version}";
        sha256 = "dad79704ce5440f3d5a3681c8590b9dc25d1a561e8f5a9c995281012860901e3";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.20.0";

      src = fetchHex {
        pkg = "postgrex";
        version = "${version}";
        sha256 = "d36ef8b36f323d29505314f704e21a1a038e2dc387c6409ee0cd24144e187c0f";
      };

      beamDeps = [db_connection decimal jason];
    };

    prometheus = buildRebar3 rec {
      name = "prometheus";
      version = "4.13.0";

      src = fetchHex {
        pkg = "prometheus";
        version = "${version}";
        sha256 = "e5d9e0385ec2f650dcabb8636257ed8b3b4b211188047bd1a34d2b3f92f6420a";
      };

      beamDeps = [quantile_estimator];
    };

    prometheus_ecto = buildMix rec {
      name = "prometheus_ecto";
      version = "1.4.3";

      src = fetchHex {
        pkg = "prometheus_ecto";
        version = "${version}";
        sha256 = "8d66289f77f913b37eda81fd287340c17e61a447549deb28efc254532b2bed82";
      };

      beamDeps = [ecto prometheus_ex];
    };

    prometheus_phoenix = buildMix rec {
      name = "prometheus_phoenix";
      version = "1.3.0";

      src = fetchHex {
        pkg = "prometheus_phoenix";
        version = "${version}";
        sha256 = "c4d1404ac4e9d3d963da601db2a7d8ea31194f0017057fabf0cfb9bf5a6c8c75";
      };

      beamDeps = [phoenix prometheus_ex];
    };

    prometheus_plugs = buildMix rec {
      name = "prometheus_plugs";
      version = "1.1.5";

      src = fetchHex {
        pkg = "prometheus_plugs";
        version = "${version}";
        sha256 = "0273a6483ccb936d79ca19b0ab629aef0dba958697c94782bb728b920dfc6a79";
      };

      beamDeps = [accept plug prometheus_ex prometheus_process_collector];
    };

    qrcode = buildMix rec {
      name = "qrcode";
      version = "0.1.5";

      src = fetchHex {
        pkg = "qrcode";
        version = "${version}";
        sha256 = "a266b7fb7be0d3b713912055dde3575927eca920e5d604ded45cd534f6b7a447";
      };

      beamDeps = [];
    };

    quantile_estimator = buildRebar3 rec {
      name = "quantile_estimator";
      version = "1.0.2";

      src = fetchHex {
        pkg = "quantile_estimator";
        version = "${version}";
        sha256 = "db404793d6384995a1ac6dd973e2cee5be9fcc128765bdba53d87c564e296b64";
      };

      beamDeps = [];
    };

    que = buildMix rec {
      name = "que";
      version = "0.10.1";

      src = fetchHex {
        pkg = "que";
        version = "${version}";
        sha256 = "a737b365253e75dbd24b2d51acc1d851049e87baae08cd0c94e2bc5cd65088d5";
      };

      beamDeps = [ex_utils memento];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.1";

      src = fetchHex {
        pkg = "ranch";
        version = "${version}";
        sha256 = "aed58910f4e21deea992a67bf51632b6d60114895eb03bb392bb733064594dd0";
      };

      beamDeps = [];
    };

    recon = buildMix rec {
      name = "recon";
      version = "2.5.6";

      src = fetchHex {
        pkg = "recon";
        version = "${version}";
        sha256 = "96c6799792d735cc0f0fd0f86267e9d351e63339cbe03df9d162010cefc26bb0";
      };

      beamDeps = [];
    };

    redix = buildMix rec {
      name = "redix";
      version = "1.5.2";

      src = fetchHex {
        pkg = "redix";
        version = "${version}";
        sha256 = "78538d184231a5d6912f20567d76a49d1be7d3fca0e1aaaa20f4df8e1142dcb8";
      };

      beamDeps = [castore nimble_options telemetry];
    };

    remote_ip = buildMix rec {
      name = "remote_ip";
      version = "1.2.0";

      src = fetchHex {
        pkg = "remote_ip";
        version = "${version}";
        sha256 = "2ff91de19c48149ce19ed230a81d377186e4412552a597d6a5137373e5877cb7";
      };

      beamDeps = [combine plug];
    };

    rustler_precompiled = buildMix rec {
      name = "rustler_precompiled";
      version = "0.8.2";

      src = fetchHex {
        pkg = "rustler_precompiled";
        version = "${version}";
        sha256 = "63d1bd5f8e23096d1ff851839923162096364bac8656a4a3c00d1fff8e83ee0a";
      };

      beamDeps = [castore];
    };

    sleeplocks = buildRebar3 rec {
      name = "sleeplocks";
      version = "1.1.3";

      src = fetchHex {
        pkg = "sleeplocks";
        version = "${version}";
        sha256 = "d3b3958552e6eb16f463921e70ae7c767519ef8f5be46d7696cc1ed649421321";
      };

      beamDeps = [];
    };

    sobelow = buildMix rec {
      name = "sobelow";
      version = "0.13.0";

      src = fetchHex {
        pkg = "sobelow";
        version = "${version}";
        sha256 = "cd6e9026b85fc35d7529da14f95e85a078d9dd1907a9097b3ba6ac7ebbe34a0d";
      };

      beamDeps = [jason];
    };

    spandex = buildMix rec {
      name = "spandex";
      version = "3.2.0";

      src = fetchHex {
        pkg = "spandex";
        version = "${version}";
        sha256 = "d0a7d5aef4c5af9cf5467f2003e8a5d8d2bdae3823a6cc95d776b9a2251d4d03";
      };

      beamDeps = [decorator optimal plug];
    };

    spandex_datadog = buildMix rec {
      name = "spandex_datadog";
      version = "1.4.0";

      src = fetchHex {
        pkg = "spandex_datadog";
        version = "${version}";
        sha256 = "360f8e1b4db238c1749c4872b1697b096429927fa42b8858d0bb782067380123";
      };

      beamDeps = [msgpax spandex telemetry];
    };

    spandex_ecto = buildMix rec {
      name = "spandex_ecto";
      version = "0.7.0";

      src = fetchHex {
        pkg = "spandex_ecto";
        version = "${version}";
        sha256 = "c64784be79d95538013b7c60828830411c5c7aff1f4e8d66dfe564b3c83b500e";
      };

      beamDeps = [spandex];
    };

    spandex_phoenix = buildMix rec {
      name = "spandex_phoenix";
      version = "1.1.0";

      src = fetchHex {
        pkg = "spandex_phoenix";
        version = "${version}";
        sha256 = "265fe05c1736485fbb75d66ef7576682ebf6428c391dd54d22217f612fd4ddad";
      };

      beamDeps = [phoenix plug spandex telemetry];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.7";

      src = fetchHex {
        pkg = "ssl_verify_fun";
        version = "${version}";
        sha256 = "fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8";
      };

      beamDeps = [];
    };

    statistex = buildMix rec {
      name = "statistex";
      version = "1.0.0";

      src = fetchHex {
        pkg = "statistex";
        version = "${version}";
        sha256 = "ff9d8bee7035028ab4742ff52fc80a2aa35cece833cf5319009b52f1b5a86c27";
      };

      beamDeps = [];
    };

    sweet_xml = buildMix rec {
      name = "sweet_xml";
      version = "0.7.5";

      src = fetchHex {
        pkg = "sweet_xml";
        version = "${version}";
        sha256 = "193b28a9b12891cae351d81a0cead165ffe67df1b73fe5866d10629f4faefb12";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.3.0";

      src = fetchHex {
        pkg = "telemetry";
        version = "${version}";
        sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
      };

      beamDeps = [];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.13.2";

      src = fetchHex {
        pkg = "tesla";
        version = "${version}";
        sha256 = "960609848f1ef654c3cdfad68453cd84a5febecb6ed9fed9416e36cd9cd724f9";
      };

      beamDeps = [castore exjsx hackney jason mime mint mox msgpax poison telemetry];
    };

    timex = buildMix rec {
      name = "timex";
      version = "3.7.11";

      src = fetchHex {
        pkg = "timex";
        version = "${version}";
        sha256 = "8b9024f7efbabaf9bd7aa04f65cf8dcd7c9818ca5737677c7b76acbc6a94d1aa";
      };

      beamDeps = [combine gettext tzdata];
    };

    typed_ecto_schema = buildMix rec {
      name = "typed_ecto_schema";
      version = "0.4.1";

      src = fetchHex {
        pkg = "typed_ecto_schema";
        version = "${version}";
        sha256 = "85c6962f79d35bf543dd5659c6adc340fd2480cacc6f25d2cc2933ea6e8fcb3b";
      };

      beamDeps = [ecto];
    };

    tzdata = buildMix rec {
      name = "tzdata";
      version = "1.1.3";

      src = fetchHex {
        pkg = "tzdata";
        version = "${version}";
        sha256 = "d4ca85575a064d29d4e94253ee95912edfb165938743dbf002acdf0dcecb0c28";
      };

      beamDeps = [hackney];
    };

    ueberauth = buildMix rec {
      name = "ueberauth";
      version = "0.10.8";

      src = fetchHex {
        pkg = "ueberauth";
        version = "${version}";
        sha256 = "f2d3172e52821375bccb8460e5fa5cb91cfd60b19b636b6e57e9759b6f8c10c1";
      };

      beamDeps = [plug];
    };

    ueberauth_auth0 = buildMix rec {
      name = "ueberauth_auth0";
      version = "2.1.0";

      src = fetchHex {
        pkg = "ueberauth_auth0";
        version = "${version}";
        sha256 = "8d3b30fa27c95c9e82c30c4afb016251405706d2e9627e603c3c9787fd1314fc";
      };

      beamDeps = [oauth2 ueberauth];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "unicode_util_compat";
        version = "${version}";
        sha256 = "25eee6d67df61960cf6a794239566599b09e17e668d3700247bc498638152521";
      };

      beamDeps = [];
    };

    unsafe = buildMix rec {
      name = "unsafe";
      version = "1.0.2";

      src = fetchHex {
        pkg = "unsafe";
        version = "${version}";
        sha256 = "b485231683c3ab01a9cd44cb4a79f152c6f3bb87358439c6f68791b85c2df675";
      };

      beamDeps = [];
    };

    varint = buildMix rec {
      name = "varint";
      version = "1.5.1";

      src = fetchHex {
        pkg = "varint";
        version = "${version}";
        sha256 = "24f3deb61e91cb988056de79d06f01161dd01be5e0acae61d8d936a552f1be73";
      };

      beamDeps = [];
    };

    wallaby = buildMix rec {
      name = "wallaby";
      version = "0.30.10";

      src = fetchHex {
        pkg = "wallaby";
        version = "${version}";
        sha256 = "a8f89b92d8acce37a94b5dfae6075c2ef00cb3689d6333f5f36c04b381c077b2";
      };

      beamDeps = [ecto_sql httpoison jason phoenix_ecto web_driver_client];
    };

    web_driver_client = buildMix rec {
      name = "web_driver_client";
      version = "0.2.0";

      src = fetchHex {
        pkg = "web_driver_client";
        version = "${version}";
        sha256 = "83cc6092bc3e74926d1c8455f0ce927d5d1d36707b74d9a65e38c084aab0350f";
      };

      beamDeps = [hackney jason tesla];
    };

    websockex = buildMix rec {
      name = "websockex";
      version = "0.4.3";

      src = fetchHex {
        pkg = "websockex";
        version = "${version}";
        sha256 = "95f2e7072b85a3a4cc385602d42115b73ce0b74a9121d0d6dbbf557645ac53e4";
      };

      beamDeps = [];
    };
  };
in
  self
