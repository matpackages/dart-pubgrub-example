import 'util.dart';
import 'versions.dart';

void main() async {
    var packageFile = 'universes/elm/elm-packages.json';
    var packages = readTest(packageFile);
    var server = await startPackageServer(packages);
    var name = 'AdrianRibao_elm_derberos_date';
    var version = '1.0.0';
    var root = packages[name][version];
    print('${name}/${version}:');
    await solveVersions('cache', 'root', parseConstraints(root), server.url);
    print('');
    await server.close();
}
