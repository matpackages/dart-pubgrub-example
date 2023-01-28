import 'pub/lib/src/solver.dart';
import 'pub/lib/src/lock_file.dart';
import 'pub/lib/src/system_cache.dart';
import 'pub/lib/src/package.dart';
import 'pub/lib/src/pubspec.dart';

void main() async {
    var type = SolveType.get;
    var cacheDir = "temp/cache";
    var cache = SystemCache(rootDir: cacheDir, isOffline: false);
    var root = package('root', {"foo":">=1.0.0 <2.0.0"}, cache.hosted);
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

void printResult(result) {
    for (var package in result.packages) {
        print(package.toString());
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
