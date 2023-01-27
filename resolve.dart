import 'pub/lib/src/solver.dart';
import 'pub/lib/src/lock_file.dart';
import 'pub/lib/src/system_cache.dart';
import 'pub/lib/src/package.dart';

void main() async {
    var type = SolveType.get;
    var cache = SystemCache(isOffline: false);
    var rootDir = '.';
    var root = Package.load(
        null,
        rootDir,
        cache.sources,
        withPubspecOverrides: true,
    );
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
