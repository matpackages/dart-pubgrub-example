# dart-pubgrub-example

Minimal examples to solve dependency resolution problems using the original PubGrub implementation in Dart.

## Setup

First you have to install the current [Dart SDK](https://dart.dev/get-dart).

Then, clone the `pub` git repository into the subdirectory `pub`:

    git clone https://github.com/dart-lang/pub.git

Install dependencies:

    dart pub get

## Run

Run test cases:

    bash run_main.sh

Debug `main.dart` using VS Code to inspect what is happening inside the PubGrub algorithm.

## Run on Elm package universe

The file `universes/elm/elm-packages.json` has been created by the script `convert_graph.py` from the file `graph.json`, which was downloaded using the script `download.py` on 2023-02-25 at 12:01 UTC. Both scripts are from [elm-package-benchmark](https://github.com/matlabpackages/elm-package-benchmark).

Solve every version of every package of the Elm universe using `universes/elm/graph.json` as input file:

    bash run_elm.sh

This saves the output file `universes/elm/elm.json` containing the version solving results.
