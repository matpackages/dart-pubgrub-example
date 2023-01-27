import 'pub/test/descriptor.dart' as d;
import 'pub/test/test_pub.dart';

void main() async {
    var project = 'temp/myapp';
    var root = {'a': '1.0.0', 'b': '1.0.0'};
    Map<String, Map<String, Map<String, dynamic>>> packages = {
        'a': {'1.0.0': {'aa': '1.0.0', 'ab': '1.0.0'}},
        'aa': {'1.0.0': {}},
        'ab': {'1.0.0': {}},
        'b': {'1.0.0': {'ba': '1.0.0', 'bb': '1.0.0'}},
        'ba': {'1.0.0': {}},
        'bb': {'1.0.0': {}}
    };

    await startPackageServer(project, root, packages);
}

void startPackageServer(project, rootDeps, packages) async {
    var server = await PackageServer.start();

    for (var name in packages.keys) {
        for (var version in packages[name].keys) {
            var deps = packages[name][version];
            server.serve(name, version, deps: deps);
        }
    }
    print(server.url);

    var yamlFile = d.appPubspec(dependencies: rootDeps);
    await yamlFile.create(project);

    while (true) {
        await Future.delayed(Duration(seconds: 1));
    }
}
