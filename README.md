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

If you want to run PubGub on the Julia package universe, you have to modify the source code of package `pub_semver`
first, to allow a set union of version ranges. First, find out what version of `pub_semver` is installed by running:

    dart pub deps | grep 'pub_semver '

This should print something like `pub_semver 2.1.3`. Now open the file `version_constraint.dart` of this version:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/version_constraint.dart

In this file in function `VersionConstraint.parse` (line 47), replace the beginning of the function:

```dart
factory VersionConstraint.parse(String text) {
  var originalText = text;
  ...
```

with 

```dart
factory VersionConstraint.parse(String text) {
  if (text.contains(' or ')) {
      var parts = text.split(' or ');
      return VersionConstraint.unionOf(parts.map((p) => VersionConstraint.parse(p)));
  }
  var originalText = text;
  ...
```

### Fix issue with merging version constraints

[Issue](https://github.com/dart-lang/pub_semver/issues/84) filed on GitHub.

Open `version_range.dart`:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/version_range.dart

In the function `VersionConstraint union(VersionConstraint other)` do the following changes (around line 247):

```dart
      var edgesTouch = (max != null &&
              //max == other.min && // <- remove this
              (other.min != null && equalsWithoutPreRelease(max!, other.min!)) && // <- add this
              (includeMax || other.includeMin)) ||
          (min != null && min == other.max && (includeMin || other.includeMax));
```

In the same function do also the following changes (around line 231):

```dart
      if (max != null && equalsWithoutPreRelease(other, max!)) { // <- this was changed
        return VersionRange(
            min: min,
            max: max,
            includeMin: includeMin,
            includeMax: true,
            alwaysIncludeMaxPreRelease: true);
```

Open `utils.dart`:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/utils.dart

Replace the function `areAdjacent` with the following one:

```dart
bool areAdjacent(VersionRange range1, VersionRange range2) {
  // if (range1.max != range2.min) return false;
  if (range1.max == null || range2.min == null) return false;
  if (!equalsWithoutPreRelease(range1.max!, range2.min!)) return false;

  return (range1.includeMax && !range2.includeMin) ||
      (!range1.includeMax && range2.includeMin);
}
```

### Run

Solve every version of every package of the Julia universe using `universes/julia/julia-packages.json` as input file (this file has been created using the script `convert.py` from [julia-package-universe](https://github.com/matlabpackages/julia-package-universe)):

    bash run_universe.sh julia

This takes about one hour and saves the output file `universes/julia/julia-result.json` containing the version solving results.

## Develop

see [Debugging PubGrub](debugging.md)
