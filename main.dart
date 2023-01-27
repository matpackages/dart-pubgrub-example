import 'dart:convert';
import 'dart:io';
import 'pub/test/descriptor.dart' as d;
import 'pub/test/test_pub.dart';

void main() async {
    var project = 'temp/myapp';
    var file = 'test_case.json';
    var jsonString = File(file).readAsStringSync();
    var data = jsonDecode(jsonString);
    var root = data['root'];
    var packages = data['packages'];

    await startPackageServer(project, root, packages);
}

void startPackageServer(project, rootDeps, packages) async {
    var server = await PackageServer.start();

    for (var name in packages.keys) {
        for (var version in packages[name].keys) {
            if (packages[name][version].isEmpty) {
                server.serve(name, version);
            } else {
                server.serve(name, version, deps: packages[name][version]);
            }
        }
    }
    print(server.url);

    var yamlFile = d.appPubspec(dependencies: rootDeps);
    await yamlFile.create(project);

    while (true) {
        await Future.delayed(Duration(seconds: 1));
    }
}
