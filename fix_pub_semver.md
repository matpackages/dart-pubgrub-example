# Fix `pub_semver` manually

This guide shows the steps to fix the package `pub_semver` manually before running PubGrub on the Julia package universe.

## Allow multiple version ranges

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

## Fix issue with merging version constraints

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
            max: max! >= other ? max! : other,  // <- this was changed (strip prerelease)
            includeMin: includeMin,
            includeMax: true,
            alwaysIncludeMaxPreRelease: true);
```

Also add the following line (twice) after checking for `Version`, and `VersionRange`, respectively:

```dart
    if (other is Version) {
      if (allows(other)) return this;

      if (isPatchGap(this, other)) return mergePatchGap(this, other);  // <- add this
      ...
```

and

```dart
    if (other is VersionRange) {
      if (isPatchGap(this, other)) return mergePatchGap(this, other); // <- add this
      ...
```

Open `utils.dart`:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/utils.dart

Replace the function `areAdjacent` with the following one:

```dart
bool areAdjacent(VersionRange range1, VersionRange range2) {
  // if (range1.max != range2.min) return false;
  if (isPatchGap(range1, range2)) return true;
  if (range1.max == null || range2.min == null) return false;
  if (!equalsWithoutPreRelease(range1.max!, range2.min!)) return false;

  return (range1.includeMax && !range2.includeMin) ||
      (!range1.includeMax && range2.includeMin);
}
```

Add the following new functions at the end of the file:
```dart
// New functions
bool isPatchGap(VersionRange range1, VersionRange range2) {
  // true if no version number fits between max allowed version of range1 and min allowed version of range2
  return range1.max != null && range2.min != null && range1.includeMax && range2.includeMin && range1.max!.nextPatch == range2.min!;
}

VersionRange mergePatchGap(VersionRange range1, VersionRange range2) {
  return VersionRange(
    min: range1.min,
    max: range2.max,
    includeMin: range1.includeMin,
    includeMax: range2.includeMax,
    alwaysIncludeMaxPreRelease: true);
}

bool allowsSingleVersionPreReleases(VersionRange range) {
  return range.min != null && range.max != null && range.includeMin && 
    !range.includeMax && equalsWithoutPreRelease(range.min!, range.max!);
}
```

Open `version.dart`:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/version.dart

and add in the funtion `union`:

```dart
  VersionConstraint union(VersionConstraint other) {
    if (other.allows(this)) return other;

    if (other is VersionRange) {
      if (isPatchGap(this, other)) return mergePatchGap(this, other); // <- add this
      ...
```

and at the beginning of the file, add:

```dart
import 'utils.dart';
```

Open `version_union.dart`:

    code ~/.pub-cache/hosted/pub.dev/pub_semver-2.1.3/lib/src/version_union.dart

In the function `difference` add the following line near the end of the function (around line 195):

```dart
    ...

    newRanges = newRanges.where((r) => !allowsSingleVersionPreReleases(r)).toList();  // <- add this

    if (newRanges.isEmpty) return VersionConstraint.empty;
    if (newRanges.length == 1) return newRanges.single;
    return VersionUnion.fromRanges(newRanges);
  }
```
