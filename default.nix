{ mkDerivation, aeson, base, containers, hpack, hspec, http-client
, http-types, servant, servant-client, servant-elm, servant-server
, stdenv, transformers, wai, wai-make-assets, warp
}:
mkDerivation {
  pname = "example-servant-elm";
  version = "0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson base containers servant servant-elm servant-server
    transformers wai wai-make-assets warp
  ];
  testHaskellDepends = [
    aeson base containers hspec http-client http-types servant
    servant-client servant-elm servant-server transformers wai
    wai-make-assets warp
  ];
  preConfigure = "hpack";
  license = stdenv.lib.licenses.unfree;
  hydraPlatforms = stdenv.lib.platforms.none;
}
