with import <nixpkgs> {};
let 
  nixpkgs18_11 = import (fetchFromGitHub {
                   owner="NixOS";
                   repo="nixpkgs";
                   rev="866b1dbedaf84a0cc5721c475ec4196dc76ae906";
                   sha256="1kblflrvb4yqhkz9pdfkb33q4kzvkxf5ggl6b271qs7s2z1hn7j4";
  }) {};

  hpsWithHoogle = nixpkgs18_11.haskellPackages.override 
  {
     overrides = (self: super: {
        ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
        ghcWithPackages = self.ghc.withPackages;
     });
  };

  server = hpsWithHoogle.callPackage (import ./default.nix) 
  {
     wai-make-assets =  nixpkgs18_11.haskell.lib.dontCheck haskellPackages.wai-make-assets;
  };

  #Haskell IDE Engine
  hie = (import (fetchFromGitHub {
                   owner="domenkozar";
                   repo="hie-nix";
                   rev="a270d8d";
                   sha256="0hilxgmh5aaxg37cbdwixwnnripvjqxbvi8cjzqrk7rpfafv352q";
                 }) {}).hie84;


  vsCodeApps = with hpsWithHoogle; with nixpkgs18_11; [
        cabal-install
        cabal2nix
        gcc
        ghc
        stack
        hdevtools


        hie
        hoogle

  ];

  vscode = 
    #buildVSCode can be found in https://github.com/countoren/nixpkgs/blob/master/config.nix
    buildVSCode {
      settingsFile = ../vscode/settings.nix;
      additionalPostFixup = ''
        wrapProgram $out/bin/code --prefix PATH : ${lib.makeBinPath vsCodeApps}
      '';
      vscodeMatketExtensions = [
          #Elm
          {
            name = "elm";
            publisher = "sbrink";
            version = "0.22.0";
            sha256 = "0dcs89njq8fcbjhpy3i990fpp0i9klhxld76r55irr34hswry5rb";
          }
          {
            name = "vscode-html-to-elm";
            publisher = "Rubymaniac";
            version = "0.0.3";
            sha256 = "1j6qadgincgw2m3ccmr011qw4g7vmvpq1r9qq6caadhs1ny6l7j1";
          }
          {
            name = "vim";
            publisher = "vscodevim";
            version = "0.16.9";
            sha256 = "0y12asjx3z3wlpb6vdh7qnl5qkf439rv790pf9wlyigay2ayv73b";
          }

          #Haskell
          {
            name = "language-haskell";
            publisher = "justusadam";
            version = "2.5.0";
            sha256 = "10jqj8qw5x6da9l8zhjbra3xcbrwb4cpwc3ygsy29mam5pd8g6b3";
          }
          {
            name = "haskell-linter";
            publisher = "hoovercj";
            version = "0.0.6";
            sha256 = "0fb71cbjx1pyrjhi5ak29wj23b874b5hqjbh68njs61vkr3jlf1j";
          }
          {
            name = "vscode-hie-server";
            publisher = "alanz";
            version = "0.0.24";
            sha256 = "06dm6x6jnqgraims38qzf06yk9acr0ws2hx8i9fsrilv99pc9ryr";
          }
          {
            name = "phoityne-vscode";
            publisher = "phoityne";
            version = "0.0.19";
            sha256 = "0pvr1g60mfhdgs8ri0js2m2l7n99qh522gr0mxrnjdqa9sjapwyi";
          }
        ];
      };
  

in
  server.env.overrideAttrs(self: {
    buildInputs = self.buildInputs ++ vscode.buildInputs;
    shellHook = self.shellHook + vscode.shellHook;
  })
