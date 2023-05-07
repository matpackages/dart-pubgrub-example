# dart-pubgrub-example

Minimal examples to solve dependency resolution problems using the original PubGrub implementation in Dart.

## Setup

First you have to install the current [Dart SDK](https://dart.dev/get-dart).

Then, clone the `pub` git repository into the subdirectory `pub`:

    git clone https://github.com/dart-lang/pub.git
    # for best reproducability also use:
    cd pub && git checkout 14b13103acff082b9657848c449132a51ffb278f
    cd -

Install dependencies:

    dart pub get

## Run

Run test cases:

    bash run_main.sh

Debug `main.dart` using VS Code to inspect what is happening inside the PubGrub algorithm.

## Run on Elm package universe

The file `universes/elm/elm-packages.json` has been created by the script `convert_graph.py` from the file `graph.json`, which was downloaded using the script `download.py` on 2023-02-25 at 12:01 UTC. Both scripts are from [elm-package-benchmark](https://github.com/matlabpackages/elm-package-benchmark).

Solve every version of every package of the Elm universe using `universes/elm/elm-packages.json` as input file:

    bash run_universe.sh elm

This takes about 30 seconds and saves the output file `universes/elm/elm-result.json` containing the version solving results.

## Run on Julia package universe

### Preparation

If you want to run PubGub on the Julia package universe, you have to modify the source code of package `pub_semver` first, to allow a set union of version ranges. Use the following script to patch the files (use `bash pub_semver.sh restore` to restore the original version)

```bash
bash pub_semver.sh patch
```

Alternatively, it can also be done [manually using this guide](fix_pub_semver.md).

### Run

Solve every version of every package of the Julia universe using `universes/julia/julia-packages.json` as input file (this file has been created using the script `convert.py` from [julia-package-universe](https://github.com/matlabpackages/julia-package-universe)):

    bash run_universe.sh julia

This takes about one hour and saves the output file `universes/julia/julia-result.json` containing the version solving results.

## Develop

see [Debugging PubGrub](debugging.md)
