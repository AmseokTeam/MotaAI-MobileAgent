import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/core/pc_bridge/project_bridge_models.dart';

void main() {
  test('detectProjectLanguage maps common file extensions', () {
    expect(detectProjectLanguage('lib/main.dart'), 'dart');
    expect(detectProjectLanguage('pubspec.yaml'), 'yaml');
    expect(detectProjectLanguage('README.md'), 'markdown');
    expect(detectProjectLanguage('assets/data.json'), 'json');
    expect(detectProjectLanguage('Dockerfile'), 'dockerfile');
    expect(detectProjectLanguage('unknown.lock'), 'plaintext');
  });

  test('parseProjectDiff groups files and classifies diff lines', () {
    final files = parseProjectDiff('''
diff --git a/lib/main.dart b/lib/main.dart
index 1111111..2222222 100644
--- a/lib/main.dart
+++ b/lib/main.dart
@@ -1,3 +1,3 @@
-void oldMain() {}
+void main() {}
 context
''');

    expect(files, hasLength(1));
    expect(files.first.path, 'lib/main.dart');
    expect(
      files.first.lines.map((line) => line.type),
      containsAllInOrder([
        ProjectDiffLineType.header,
        ProjectDiffLineType.hunk,
        ProjectDiffLineType.removed,
        ProjectDiffLineType.added,
        ProjectDiffLineType.context,
      ]),
    );
  });

  test('parseProjectDiff returns no files for empty diff', () {
    expect(parseProjectDiff(''), isEmpty);
    expect(parseProjectDiff('   \n'), isEmpty);
  });
}
