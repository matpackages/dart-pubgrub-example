import 'dart:convert';
import 'dart:io';
import 'pub/test/test_pub.dart';
import 'pub/lib/src/package.dart';
import 'pub/lib/src/pubspec.dart';
import 'pub/lib/src/lock_file.dart';
import 'pub/lib/src/solver.dart';
import 'cache.dart';
import 'versions.dart';

void runTest(file) async {
    print(file);
    var data = readJson(file);
    var server = await startPackageServer(data['packages']);
    await solveVersions('cache', 'root', parseConstraints(data['root']), server.url);
    await server.close();
    print('');
}

dynamic readJson (file) {
    var jsonString = File(file).readAsStringSync();
    return jsonDecode(jsonString);
}

void writeJson (file, dynamic content) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    var jsonString = encoder.convert(content);
    File(file).writeAsStringSync(jsonString);
}

Future<PackageServer> startPackageServer(packages) async {
    var server = await PackageServer.start();

    for (var name in packages.keys) {
        for (var version in packages[name].keys) {
            var deps = parseConstraints(packages[name][version]);
            server.serve(name, version, deps: deps);
        }
    }
    return server;
}

dynamic solveVersions (cacheDir, rootName, rootDeps, url) async {
    var type = SolveType.get;
    var cache = TestSystemCache(rootDir: cacheDir, url: url);
    var root = package(rootName, rootDeps, cache.hosted);
    var lockFile = LockFile.empty();
    var result;
    try {
        result = await resolveVersions(
            type,
            cache,
            root,
            lockFile: lockFile,
            unlock: [],
        );
        printResult(result);
    } on SolveFailure catch (e) {
        printFailure(e);
        result = e;
    }
    return result;
}

void printResult(SolveResult result) {
    var m = toMap(result);
    for (var item in m.entries) {
        print('${item.key} ${item.value}');
    }
}

Map<String, String> toMap(SolveResult result) {
  Map<String, String> m = {};
  result.packages.sort((a, b) => a.name.compareTo(b.name));
    for (var package in result.packages) {
        if (!package.isRoot) {
            m[package.name] = package.version.toString();
        }
    }
    return m;
}

void printFailure(exception) {
    print(exception);
}

Package package(name, deps, source) {
    var pubspec = Pubspec.fromMap({
        'name': name,
        'dependencies': deps,
        'environment': {'sdk': '^3.0.2'}
    }, (name) => source);
    return Package.inMemory(pubspec);
}
