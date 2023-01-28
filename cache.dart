import 'dart:typed_data';
import 'package:pub_semver/src/version.dart';
import 'pub/lib/src/source/cached.dart';
import 'pub/lib/src/source.dart';
import 'pub/lib/src/pubspec.dart';
import 'pub/lib/src/package_name.dart';
import 'pub/lib/src/package.dart';
import 'pub/lib/src/language_version.dart';
import 'pub/lib/src/system_cache.dart';
import 'pub/lib/src/source/hosted.dart';

class TestSystemCache extends SystemCache {
    String url;

    @override
    TestHostedSource get hosted => TestHostedSource(url);

    TestSystemCache({ String rootDir='', String this.url }) : super(rootDir: rootDir, isOffline: false);
}

class TestHostedSource implements HostedSource {
  String url;

  TestHostedSource(this.url);

  @override
  String get defaultUrl => url;

  @override
  Future<Pubspec> describeUncached(PackageId id, SystemCache cache) {
    throw UnimplementedError('1');
  }

  @override
  Future<Pubspec> doDescribe(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  String doGetDirectory(PackageId id, SystemCache cache, {String relativeFrom}) {
    throw UnimplementedError();
  }

  @override
  Future<List<PackageId>> doGetVersions(PackageRef ref, Duration maxAge, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  Future<DownloadPackageResult> downloadToSystemCache(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  List<Package> getCachedPackages(SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  String getDirectoryInCache(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  bool get hasMultipleVersions => throw UnimplementedError();

  @override
  String hashPath(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  bool isInSystemCache(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  String get name => throw UnimplementedError();

  @override
  PackageId parseId(String name, Version version, description, {String containingDir}) {

    throw UnimplementedError();
  }

  @override
  PackageRef parseRef(String name, description, {String containingDir, LanguageVersion languageVersion}) {
    return PackageRef(name, HostedDescription(name, url));
  }

  @override
  Future<PackageId> preloadPackage(String archivePath, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  PackageRef refFor(String name, {String url}) {
    throw UnimplementedError();
  }

  @override
  Future<Iterable<RepairResult>> repairCachedPackages(SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  Uint8List sha256FromCache(PackageId id, SystemCache cache) {
    throw UnimplementedError();
  }

  @override
  Future<PackageStatus> status(PackageRef ref, Version version, SystemCache cache, {Duration maxAge}) {
    throw UnimplementedError();
  }

  @override
  Future<T> withPrefetching<T>(Future<T> Function() callback) async {
    return await callback();
  }

  @override
  void writeHash(PackageId id, SystemCache cache, List<int> bytes) {
    throw UnimplementedError();
  }
}
