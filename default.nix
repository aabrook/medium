with (import <nixpkgs> {});
let
  elixir = elixir_1_6;
in stdenv.mkDerivation {
  name = "my_elixir_app";
  PGDATA = "./data";

  buildInputs = [
    postgresql
    elixir
  ];
}
