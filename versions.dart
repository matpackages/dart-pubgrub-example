String parseConstraint(String spec) {
    // convert spec from format '3.0.0 - 4.*.*' to '>=3.0.0 <5.0.0'
    if (spec == '*') {
        return 'any';
    }
    if (spec.contains(',')) {
        var parts = spec.split(', ');
        return parts.map((range) => parseRange(range)).toList().join(' or ');
    } else {
        return parseRange(spec);
    }
}

String parseRange(String range) {
    var parts = range.split(' - ');
    if (parts.length == 1) {
        return range;
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

String prevVersion(String ver) {
    if (ver.contains('*')) {
        throw Exception('a version with * has no previous version');
    }
    var parts = ver.split('.');
    var major = int.parse(parts[0]);
    var minor = int.parse(parts[1]);
    var patch = int.parse(parts[2]);
    String v;
    if (patch != 0) {
        v = version(major, minor, patch - 1);
    } else if (minor != 0) {
        v = '${major}.${minor-1}.*';
    } else if (major != 0) {
        v = '${major-1}.*.*';
    } else {
        throw Exception('0.0.0 has no previous version');
    }
    return v;
}

String version(major, minor, patch) {
    return '${major}.${minor}.${patch}';
}

String toMatlabString(String s) {
  String semver = r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)';
  var sNew = s.replaceAll('root', 'root (1.0.0)');
  sNew = sNew.replaceAllMapped(RegExp(' ${semver}'), (Match m) => ' (${m[1]}.${m[2]}.${m[3]})');
  sNew = sNew.replaceAllMapped(RegExp(r'\^' + '${semver}'), (Match m) => '(${m[1]}.${m[2]}.${m[3]} - ${caretUpperBound(m[1], m[2])})');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver}) <(${semver})'), (Match m) => '(${m[1]} - ${prevVersion(m[5])})');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver}) <=(${semver})'), (Match m) => '(${m[1]} - ${m[5]})');
  sNew = sNew.replaceAllMapped(RegExp('>=(${semver})'), (Match m) => '(${m[1]} - *.*.*)');
  sNew = sNew.replaceAllMapped(RegExp('<(${semver})'), (Match m) => '(0.0.0 - ${prevVersion(m[1])})');
  sNew = sNew.replaceAllMapped(RegExp('<=(${semver})'), (Match m) => '(0.0.0 - ${m[1]})');
  sNew = sNew.replaceAll('any', '(*)');
  sNew = sNew.replaceAll('-∞', '');
  sNew = sNew.replaceAll(') or (', ', ');
  sNew = sNew.replaceAll('root (1.0.0) is (0.0.0)', 'root is 1.0.0');
  sNew = sNew.replaceAllMapped(RegExp('(${semver}) - (${semver})'), (Match m) => (m[1] == m[5]) ? '${m[1]}' : '${m[0]}');
  return sNew;
}

String caretUpperBound(String major, String minor) {
  if (major == '0') {
    return '$major.$minor.*';
  } else {
    return '$major.*.*';
  }
}
