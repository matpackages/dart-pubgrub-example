# Debugging PubGrub

For debugging you can do the following changes in `pub/lib/src/solver/version_solver.dart`:

```dart
...
import 'versions.dart';

...
class VersionSolver {
  ...
  Future<SolveResult> solve() async {
    ...
    var round = 0;
    try {
      return await _systemCache.hosted.withPrefetching(() async {
        String? next = _root.name;
        while (next != null) {
          // Print solver internal state for diagnostic purposes
          print('$round: $next');
          this.showState(next, round);
          _propagate(next);
          next = await _choosePackageVersion();
          round = round + 1;
        }

        return await _result();
      });
    }
  ...
  }

  // New functions
  void showState(String next, int round) {
    var n = 80;
    print('=' * n);
    print('VersionSolver: round: $round, next: $next');
    print('-' * n);
    this._solution.showSolution();
    print('-' * n);
    this.showIncompat();
    print('=' * n);
  }

  void showIncompat() {
    var incompatibilitiesMap = _incompatibilities;
    var k = incompatibilitiesMap.keys.toList()..sort((a, b) => a.compareTo(b));
    var nKeys = k.length;
    print('Incompatibilities: Map with $nKeys keys:');
    for (var key in k) {
      var incompats = incompatibilitiesMap[key];
      if (incompats == null) {
        return;
      }
      print('- $key (${incompats.length})');
      for (var inc in incompats) {
        var s = toMatlabString(inc.toString());
        print('  - $s');
      }
    }
  }

  ...
}

```

And in `pub/lib/src/solver/partial_solution.dart`:

```dart
...
import 'versions.dart';
...

class PartialSolution {
  ...

  void showSolution() {
    print('PartialSolution:');
    print('- attempted_solutions: $_attemptedSolutions');
    print('- backtracking: $_backtracking');
    print('- decision_level: $decisionLevel');

    print('- decisions: ${_decisions.length}');
    var keys = _decisions.keys.toList()..sort((a, b) => a.compareTo(b));
    for (var k in keys) {
      String? v = '1.0.0';
      if (k != 'root') {
        v = _decisions[k]?.version.toString();
      }
      print('  - $k: $v');
    }

    print('- unsatisfied: ${unsatisfied.length} items');
    for (var us in unsatisfied) {
      print('  - ${toMatlabString(us.toString())}');
    }

    print('- assignments: ${_assignments.length} items');
    for (var a in _assignments) {
      var s = toMatlabString(a.toString());
      print('  - $s');
    }
  }

  ...
}
```

You also have to copy the file `versions.dart` to `pub/lib/src/solver/`.
