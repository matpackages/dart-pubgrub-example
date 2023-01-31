import 'dart:convert';
import 'dart:io';
import 'pub/test/test_pub.dart';
import 'pub/lib/src/package.dart';
import 'pub/lib/src/pubspec.dart';
import 'pub/lib/src/lock_file.dart';
import 'pub/lib/src/solver.dart';
import 'cache.dart';
import 'versions.dart';

void main() async {
    await runTest('examples/simple.json');
    await runTest('examples/no-conflicts.json');
    await runTest('examples/avoid-conflict.json');
    await runTest('examples/conflict-resolution.json');
    await runTest('examples/partial-satisfier.json');
    await runTest('examples/error-linear.json');
    await runTest('examples/error-branching.json');
}

void runTest(file) async {
    print(file);
    var data = readTest(file);
    var server = await startPackageServer(data['packages']);
    await solveVersions('cache', 'root', parseConstraints(data['root']), server.url);
    await server.close();
    print('');
}

dynamic readTest (file) {
    var jsonString = File(file).readAsStringSync();
    return jsonDecode(jsonString);
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

void solveVersions (cacheDir, rootName, rootDeps, url) async {
    var type = SolveType.get;
    var cache = TestSystemCache(rootDir: cacheDir, url: url);
    var root = package(rootName, rootDeps, cache.hosted);
    var lockFile = LockFile.empty();
    try {
        var result = await resolveVersions(
            type,
            cache,
            root,
            lockFile: lockFile,
            unlock: [],
        );
        printResult(result);
    } catch (e) {
        printFailure(e);
    }
}

void printResult(SolveResult result) {
    result.packages.sort((a, b) => a.name.compareTo(b.name));
    for (var package in result.packages) {
        if (!package.isRoot) {
            print(package.toString());
        }
    }
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
