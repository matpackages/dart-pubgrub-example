import 'pub/test/descriptor.dart' as d;
import 'pub/test/test_pub.dart';

void main() async {
    var project = 'temp/myapp';
    var rootDeps = {'a': '1.0.0', 'b': '1.0.0'};

    await startPackageServer(project, rootDeps);
}

void startPackageServer(project, rootDeps) async {
    var server = await PackageServer.start();
        server
        ..serve('a', '1.0.0', deps: {'aa': '1.0.0', 'ab': '1.0.0'})
        ..serve('aa', '1.0.0')
        ..serve('ab', '1.0.0')
        ..serve('b', '1.0.0', deps: {'ba': '1.0.0', 'bb': '1.0.0'})
        ..serve('ba', '1.0.0')
        ..serve('bb', '1.0.0');
    print(server.url);

    var yamlFile = d.appPubspec(dependencies: rootDeps);
    await yamlFile.create(project);

    while (true) {
        await Future.delayed(Duration(seconds: 1));
    }
}
