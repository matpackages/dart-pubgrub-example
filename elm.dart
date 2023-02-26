import 'util.dart';
import 'versions.dart';
import 'pub/lib/src/solver.dart';

void main() async {
    var packageFile = 'universes/elm/elm-packages.json';
    var resultFile = 'universes/elm/elm-result.json';
    var packages = readJson(packageFile);
    var server = await startPackageServer(packages);
    var results = {};
    int nFailures = 0;
    for (var name in packages.keys) {
      results[name] = {};
      for (var version in packages[name].keys) {
        var root = packages[name][version];
        print('${name}/${version}:');
        var result = await solveVersions('cache', 'root', parseConstraints(root), server.url);
        dynamic r;
        if (result is SolveResult) {
          r = {'solution': toMap(result)};
        } else {
          nFailures += 1;
          r = {'failure': toPlainString(result.message).split('\n')};
        }
        results[name][version] = r;
        print('');
      }
    }
    writeJson(resultFile, results);
    print('version solving failed ${nFailures} times.');
    await server.close();
}

String toPlainString(String s) {
  String sNew = s;
  if (s.endsWith('\n')) {
    sNew = s.substring(0, s.length-1);
  }
  // replace bold text to normal text
  sNew = sNew.replaceAll('\u001b[1m', '').replaceAll('\u001b[0m', '');
  return sNew;
}
