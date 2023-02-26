import 'util.dart';
import 'versions.dart';
import 'pub/lib/src/solver.dart';

void main() async {
    var packageFile = 'universes/elm/elm-packages.json';
    var resultFile = 'universes/elm/elm-result.json';
    var packages = readJson(packageFile);
    var server = await startPackageServer(packages);
    var name = 'AdrianRibao_elm_derberos_date';
    var results = {};
    results[name] = {};
    for (var version in packages[name].keys) {
      var root = packages[name][version];
      print('${name}/${version}:');
      var result = await solveVersions('cache', 'root', parseConstraints(root), server.url);
      dynamic r;
      if (result is SolveResult) {
        r = {'solution': toMap(result)};
      } else {
        r = {'failure': toPlainString(result.message).split('\n')};
      }
      results[name][version] = r;
      print('');
    }
    print(results);
    writeJson(resultFile, results);
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
