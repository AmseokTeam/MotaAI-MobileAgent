// 文件作用：定义 MotaLink 项目浏览协议中的目录、文件和 diff 数据模型。

enum ProjectEntryType {
  directory,
  file,
}

class ProjectEntry {
  const ProjectEntry({
    required this.name,
    required this.path,
    required this.type,
    this.size,
  });

  factory ProjectEntry.fromJson(Map<String, dynamic> json) {
    return ProjectEntry(
      name: _readString(json['name']) ?? '',
      path: _readString(json['path']) ?? '',
      type: _readEntryType(json['type']),
      size: _readInt(json['size']),
    );
  }

  final String name;
  final String path;
  final ProjectEntryType type;
  final int? size;

  bool get isDirectory => type == ProjectEntryType.directory;
}

class ProjectDirectoryListing {
  const ProjectDirectoryListing({
    required this.path,
    required this.entries,
  });

  factory ProjectDirectoryListing.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = <ProjectEntry>[];
    if (rawEntries is List) {
      for (final rawEntry in rawEntries) {
        if (rawEntry is Map<String, dynamic>) {
          final entry = ProjectEntry.fromJson(rawEntry);
          if (entry.name.isNotEmpty && entry.path.isNotEmpty) {
            entries.add(entry);
          }
        }
      }
    }

    entries.sort((left, right) {
      if (left.isDirectory != right.isDirectory) {
        return left.isDirectory ? -1 : 1;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return ProjectDirectoryListing(
      path: _readString(json['path']) ?? '.',
      entries: entries,
    );
  }

  final String path;
  final List<ProjectEntry> entries;
}

class ProjectFileContent {
  const ProjectFileContent({
    required this.path,
    required this.content,
    required this.language,
    required this.truncated,
  });

  factory ProjectFileContent.fromJson(Map<String, dynamic> json) {
    final path = _readString(json['path']) ?? '';
    return ProjectFileContent(
      path: path,
      content: _readString(json['content'], allowEmpty: true) ?? '',
      language: detectProjectLanguage(
        path,
        _readString(json['language']),
      ),
      truncated: json['truncated'] == true,
    );
  }

  final String path;
  final String content;
  final String language;
  final bool truncated;
}

String detectProjectLanguage(String path, [String? serverLanguage]) {
  final explicitLanguage = serverLanguage?.trim().toLowerCase();
  if (explicitLanguage != null && explicitLanguage.isNotEmpty) {
    return explicitLanguage;
  }

  final lowerPath = path.toLowerCase();
  final filename = lowerPath.split('/').last;
  if (filename == 'dockerfile') {
    return 'dockerfile';
  }
  if (filename == 'makefile') {
    return 'makefile';
  }

  final extensionStart = filename.lastIndexOf('.');
  if (extensionStart == -1 || extensionStart == filename.length - 1) {
    return 'plaintext';
  }

  return switch (filename.substring(extensionStart + 1)) {
    'dart' => 'dart',
    'json' => 'json',
    'md' || 'markdown' => 'markdown',
    'yaml' || 'yml' => 'yaml',
    'js' || 'mjs' || 'cjs' => 'javascript',
    'ts' || 'tsx' => 'typescript',
    'html' || 'htm' => 'xml',
    'css' => 'css',
    'scss' => 'scss',
    'kt' || 'kts' => 'kotlin',
    'swift' => 'swift',
    'java' => 'java',
    'py' => 'python',
    'go' => 'go',
    'rs' => 'rust',
    'sh' || 'bash' || 'zsh' => 'bash',
    'xml' => 'xml',
    'gradle' => 'gradle',
    'properties' => 'properties',
    _ => 'plaintext',
  };
}

enum ProjectDiffLineType {
  header,
  hunk,
  added,
  removed,
  context,
}

class ProjectDiffLine {
  const ProjectDiffLine({
    required this.type,
    required this.text,
  });

  final ProjectDiffLineType type;
  final String text;
}

class ProjectDiffFile {
  const ProjectDiffFile({
    required this.path,
    required this.lines,
  });

  final String path;
  final List<ProjectDiffLine> lines;
}

List<ProjectDiffFile> parseProjectDiff(String diff) {
  if (diff.trim().isEmpty) {
    return const <ProjectDiffFile>[];
  }

  final files = <_MutableProjectDiffFile>[];
  _MutableProjectDiffFile? currentFile;

  for (final line in diff.split('\n')) {
    if (line.startsWith('diff --git ')) {
      currentFile = _MutableProjectDiffFile(path: _pathFromDiffGitLine(line));
      files.add(currentFile);
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.header,
        text: line,
      ));
      continue;
    }

    currentFile ??= _MutableProjectDiffFile(path: '修改内容');
    if (!files.contains(currentFile)) {
      files.add(currentFile);
    }

    if (line.startsWith('+++ ')) {
      currentFile.path = _normalizeDiffPath(line.substring(4));
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.header,
        text: line,
      ));
    } else if (line.startsWith('--- ')) {
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.header,
        text: line,
      ));
    } else if (line.startsWith('@@')) {
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.hunk,
        text: line,
      ));
    } else if (line.startsWith('+')) {
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.added,
        text: line,
      ));
    } else if (line.startsWith('-')) {
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.removed,
        text: line,
      ));
    } else {
      currentFile.lines.add(ProjectDiffLine(
        type: ProjectDiffLineType.context,
        text: line,
      ));
    }
  }

  return [
    for (final file in files)
      ProjectDiffFile(path: file.path, lines: List.unmodifiable(file.lines)),
  ];
}

class _MutableProjectDiffFile {
  _MutableProjectDiffFile({required this.path});

  String path;
  final List<ProjectDiffLine> lines = <ProjectDiffLine>[];
}

ProjectEntryType _readEntryType(Object? value) {
  if (value == 'directory' || value == 'dir') {
    return ProjectEntryType.directory;
  }
  return ProjectEntryType.file;
}

String? _readString(Object? value, {bool allowEmpty = false}) {
  if (value is String && (allowEmpty || value.trim().isNotEmpty)) {
    return value;
  }
  return null;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return null;
}

String _pathFromDiffGitLine(String line) {
  final parts = line.split(' ');
  if (parts.length >= 4) {
    return _normalizeDiffPath(parts[3]);
  }
  return '修改内容';
}

String _normalizeDiffPath(String path) {
  if (path == '/dev/null') {
    return path;
  }
  if (path.startsWith('a/') || path.startsWith('b/')) {
    return path.substring(2);
  }
  return path;
}
