import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
//import 'pub/test/descriptor.dart' as d;
import 'package:pub_semver/src/version.dart';

import 'pub/lib/src/source/cached.dart';
import 'pub/lib/src/source.dart';
import 'pub/lib/src/pubspec.dart';
import 'pub/lib/src/package_name.dart';
import 'pub/lib/src/package.dart';
import 'pub/lib/src/language_version.dart';
import 'pub/test/test_pub.dart';
import 'resolve.dart';
import 'pub/lib/src/system_cache.dart';
import 'pub/lib/src/lock_file.dart';
import 'pub/lib/src/solver.dart';
import 'pub/lib/src/source/hosted.dart';

void main() async {
    // var project = 'temp/myapp';
    var file = 'test_case.json';
    var data = readTest(file);
    var server = await startPackageServer(data['packages']);
    // await createRoot(project, data['root']);

    var cacheDir = "temp/cache";
    await solveVersions(cacheDir, 'root', parseConstraints(data['root']), server.url);
    await server.close();
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

/*void createRoot(project, rootDeps) async {
    var rootDependencies = parseConstraints(rootDeps);
    var yamlFile = d.appPubspec(dependencies: rootDependencies);
    await yamlFile.create(project);
}*/

void solveVersions (cacheDir, rootName, rootDeps, url) async {
    var type = SolveType.get;
    var cache = MySystemCache(rootDir: cacheDir, url: url);
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

String parseConstraint(String spec) {
    // convert spec from format '3.0.0 - 4.*.*' to '>=3.0.0 <5.0.0'
    if (spec == '*') {
        return spec;
    }
    var parts = spec.split(' - ');
    if (parts.length == 1) {
        return spec;
    }
    var lower = parts[0];
    var upper = parts[1];
    var up;
    if (upper == '*.*.*') {
        up = '';
    } else if (upper.contains('*')) {
        up = ' <${nextVersion(upper)}';
    } else {
        up = ' <= ${upper}';
    }
    var constraint = '>=${lower}${up}';
    return constraint;
}

Map<String, String> parseConstraints(deps) {
    Map<String, String> d = {};
    for (var e in deps.entries) {
        d[e.key] = parseConstraint(e.value);
    }
    return d;
}

String nextVersion(String ver) {
    var parts = ver.split('.');
    var major = parts[0];
    var minor = parts[1];
    var patch = parts[2];
    var c = '*'.allMatches(ver).length;
    if (c == 2) { 
        return version(int.parse(major) + 1, 0, 0);
    } else if (c == 1) {
        return version(int.parse(major), int.parse(minor) + 1, 0);
    } else if (c == 0) {
        return version(int.parse(major), int.parse(minor), int.parse(patch) + 1);
    } else {
        throw Exception('next version of ${ver} is not valid');
    }
}

String version(major, minor, patch) {
    return '${major}.${minor}.${patch}';
}

class MySystemCache extends SystemCache {
    String url;

    @override
    MyHostedSource get hosted => MyHostedSource(url);

    MySystemCache({ String rootDir='', String this.url }) : super(rootDir: rootDir, isOffline: false);
}

class MyHostedSource implements HostedSource {
  String url;

  MyHostedSource(this.url);

  @override
  String get defaultUrl => url;

  @override
  Future<Pubspec> describeUncached(PackageId id, SystemCache cache) {
    // TODO: implement describeUncached
    throw UnimplementedError('1');
  }

  @override
  Future<Pubspec> doDescribe(PackageId id, SystemCache cache) {
    // TODO: implement doDescribe
    throw UnimplementedError('2');
  }

  @override
  String doGetDirectory(PackageId id, SystemCache cache, {String relativeFrom}) {
    // TODO: implement doGetDirectory
    throw UnimplementedError('3');
  }

  @override
  Future<List<PackageId>> doGetVersions(PackageRef ref, Duration maxAge, SystemCache cache) {
    // TODO: implement doGetVersions
    throw UnimplementedError('4');
  }

  @override
  Future<DownloadPackageResult> downloadToSystemCache(PackageId id, SystemCache cache) {
    // TODO: implement downloadToSystemCache
    throw UnimplementedError('5');
  }

  @override
  List<Package> getCachedPackages(SystemCache cache) {
    // TODO: implement getCachedPackages
    throw UnimplementedError('6');
  }

  @override
  String getDirectoryInCache(PackageId id, SystemCache cache) {
    // TODO: implement getDirectoryInCache
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasMultipleVersions
  bool get hasMultipleVersions => throw UnimplementedError();

  @override
  String hashPath(PackageId id, SystemCache cache) {
    // TODO: implement hashPath
    throw UnimplementedError();
  }

  @override
  bool isInSystemCache(PackageId id, SystemCache cache) {
    // TODO: implement isInSystemCache
    throw UnimplementedError();
  }

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  PackageId parseId(String name, Version version, description, {String containingDir}) {
    // TODO: implement parseId
    throw UnimplementedError();
  }

  @override
  PackageRef parseRef(String name, description, {String containingDir, LanguageVersion languageVersion}) {
    return PackageRef(name, HostedDescription(name, url));
  }

  @override
  Future<PackageId> preloadPackage(String archivePath, SystemCache cache) {
    // TODO: implement preloadPackage
    throw UnimplementedError();
  }

  @override
  PackageRef refFor(String name, {String url}) {
    // TODO: implement refFor
    throw UnimplementedError();
  }

  @override
  Future<Iterable<RepairResult>> repairCachedPackages(SystemCache cache) {
    // TODO: implement repairCachedPackages
    throw UnimplementedError();
  }

  @override
  Uint8List sha256FromCache(PackageId id, SystemCache cache) {
    // TODO: implement sha256FromCache
    throw UnimplementedError();
  }

  @override
  Future<PackageStatus> status(PackageRef ref, Version version, SystemCache cache, {Duration maxAge}) {
    // TODO: implement status
    throw UnimplementedError();
  }

  @override
  Future<T> withPrefetching<T>(Future<T> Function() callback) async {
    return await callback();
  }

  @override
  void writeHash(PackageId id, SystemCache cache, List<int> bytes) {
    // TODO: implement writeHash
    throw UnimplementedError();
  }
}
