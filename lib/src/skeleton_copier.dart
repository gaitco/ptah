import 'dart:io';

import 'package:path/path.dart' as p;

/// Copies the bundled skeleton into a new project directory.
class SkeletonCopier {
  SkeletonCopier(this.sourceDir);
  final String sourceDir;

  /// `dot.gitignore` -> `.gitignore`, `pubspec.yaml.tpl` -> `pubspec.yaml`.
  static String targetRelativePath(String relative) {
    final segments = p
        .split(relative)
        .map((s) => s.startsWith('dot.') ? '.${s.substring(4)}' : s)
        .toList();
    var last = segments.last;
    if (last.endsWith('.tpl')) last = last.substring(0, last.length - 4);
    segments[segments.length - 1] = last;
    return p.joinAll(segments);
  }

  /// Copies the skeleton into [targetDir]. Files whose target-relative path
  /// satisfies [skip] are omitted — that is how `--api` drops the frontend.
  Future<List<String>> copyTo(
    String targetDir,
    Map<String, String> replacements, {
    bool Function(String relative)? skip,
  }) async {
    final written = <String>[];
    final source = Directory(sourceDir);
    await for (final entity in source.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final relative = targetRelativePath(
        p.relative(entity.path, from: sourceDir),
      );
      if (skip != null && skip(relative)) continue;
      var contents = await entity.readAsString();
      // `.khnum.html` files own `{{ }}` themselves — it is Khnum's
      // expression syntax, not a placeholder token. Substituting into them
      // collides with any component prop whose name matches a replacement
      // key (`name`, `type`, `value`, ...), so they are copied verbatim.
      if (!relative.endsWith('.khnum.html')) {
        for (final e in replacements.entries) {
          contents = contents.replaceAll(
            RegExp('\\{\\{\\s*${RegExp.escape(e.key)}\\s*\\}\\}'),
            e.value,
          );
        }
      }
      final target = File(p.join(targetDir, relative));
      await target.parent.create(recursive: true);
      await target.writeAsString(contents);
      written.add(relative);
    }
    return written;
  }
}
