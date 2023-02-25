import 'util.dart';

void main() async {
    await runTest('examples/simple.json');
    await runTest('examples/no-conflicts.json');
    await runTest('examples/avoid-conflict.json');
    await runTest('examples/conflict-resolution.json');
    await runTest('examples/partial-satisfier.json');
    await runTest('examples/error-linear.json');
    await runTest('examples/error-branching.json');
}
