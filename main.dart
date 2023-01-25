@Timeout(Duration(hours: 2))

import 'package:test/test.dart';
import 'pub/test/descriptor.dart' as d;
import 'pub/test/test_pub.dart';

void main() {
    test('simple dependency tree', () async {
        var server = await servePackages();
        server
        ..serve('a', '1.0.0', deps: {'aa': '1.0.0', 'ab': '1.0.0'})
        ..serve('aa', '1.0.0')
        ..serve('ab', '1.0.0')
        ..serve('b', '1.0.0', deps: {'ba': '1.0.0', 'bb': '1.0.0'})
        ..serve('ba', '1.0.0')
        ..serve('bb', '1.0.0');

        var deps = {'a': '1.0.0', 'b': '1.0.0'};
        var spec = d.appDir(dependencies: deps);
        var yamlFile = d.appPubspec(dependencies: deps);
        await yamlFile.create('temp/myapp');
        await spec.create();
        print(server.url);
        
        /*await expectResolves(
        result: {
            'a': '1.0.0',
            'aa': '1.0.0',
            'ab': '1.0.0',
            'b': '1.0.0',
            'ba': '1.0.0',
            'bb': '1.0.0'
        },
        );*/

        while (true) {
          await Future.delayed(Duration(seconds: 1));
        }
    }, timeout: Timeout(Duration(hours: 1)),);
}
