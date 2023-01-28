String parseConstraint(String spec) {
    // convert spec from format '3.0.0 - 4.*.*' to '>=3.0.0 <5.0.0'
    if (spec == '*') {
        return spec;
    }
    var parts = spec.split(' - ');
    if (parts.length == 1) {
        return spec;
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

String version(major, minor, patch) {
    return '${major}.${minor}.${patch}';
}
