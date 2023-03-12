import 'util.dart';
import 'versions.dart';
import 'pub/lib/src/solver.dart';

void main(List<String> args) async {
    var universe = args[0];
    var packageFile = 'universes/${universe}/${universe}-packages.json';
    var resultFile = 'universes/${universe}/${universe}-result.json';
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
          r = {'failure': correctFailureString(result.message).split('\n')};
        }
        results[name][version] = r;
        print('');
      }
    }
    writeJson(resultFile, results);
    print('version solving failed ${nFailures} times.');
    await server.close();
}

String correctFailureString(String s) {
  String sNew = s;
  if (s.endsWith('\n')) {
    sNew = s.substring(0, s.length-1);
  }
  // replace bold text to normal text
  sNew = sNew.replaceAll('\u001b[1m', '').replaceAll('\u001b[0m', '');
  // replace syntax to Matlab syntax
  String semver = r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)';
  sNew = sNew.replaceAll('root', 'root (1.0.0)');
  sNew = sNew.replaceAllMapped(RegExp(r'\^' + '${semver}'), (Match m) => '(${m[1]}.${m[2]}.${m[3]} - ${m[1]}.*.*)');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver}) <(${semver})'), (Match m) => '(${m[1]} - ${prevVersion(m[5])})');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver}) <=(${semver})'), (Match m) => '(${m[1]} - ${m[5]})');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver})'), (Match m) => '(${m[1]} - *.*.*)');
  sNew = sNew.replaceAllMapped(RegExp('<(${semver})'), (Match m) => '(0.0.0 - ${prevVersion(m[1])})');
  sNew = sNew.replaceAllMapped(RegExp('<=(${semver})'), (Match m) => '(0.0.0 - ${m[1]})');
  // sometimes upper bounds in failure message contain the string '-∞',although there are no pre-release versions
  // --> bug in Pub? --> remove this string
  sNew = sNew.replaceAll('-∞', '');
  return sNew;
}
