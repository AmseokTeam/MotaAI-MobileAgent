// 文件作用：把项目文件语言标识映射为 flutter_code_editor 可用的高亮模式。

import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/bash.dart' as bash_mode;
import 'package:highlight/languages/css.dart' as css_mode;
import 'package:highlight/languages/dart.dart' as dart_mode;
import 'package:highlight/languages/dockerfile.dart' as dockerfile_mode;
import 'package:highlight/languages/go.dart' as go_mode;
import 'package:highlight/languages/gradle.dart' as gradle_mode;
import 'package:highlight/languages/java.dart' as java_mode;
import 'package:highlight/languages/javascript.dart' as javascript_mode;
import 'package:highlight/languages/json.dart' as json_mode;
import 'package:highlight/languages/kotlin.dart' as kotlin_mode;
import 'package:highlight/languages/makefile.dart' as makefile_mode;
import 'package:highlight/languages/markdown.dart' as markdown_mode;
import 'package:highlight/languages/plaintext.dart' as plaintext_mode;
import 'package:highlight/languages/properties.dart' as properties_mode;
import 'package:highlight/languages/python.dart' as python_mode;
import 'package:highlight/languages/rust.dart' as rust_mode;
import 'package:highlight/languages/scss.dart' as scss_mode;
import 'package:highlight/languages/swift.dart' as swift_mode;
import 'package:highlight/languages/typescript.dart' as typescript_mode;
import 'package:highlight/languages/xml.dart' as xml_mode;
import 'package:highlight/languages/yaml.dart' as yaml_mode;

Mode projectCodeModeFor(String language) {
  return switch (language.trim().toLowerCase()) {
    'bash' || 'shell' || 'sh' || 'zsh' => bash_mode.bash,
    'css' => css_mode.css,
    'dart' => dart_mode.dart,
    'dockerfile' => dockerfile_mode.dockerfile,
    'go' => go_mode.go,
    'gradle' => gradle_mode.gradle,
    'java' => java_mode.java,
    'javascript' || 'js' => javascript_mode.javascript,
    'json' => json_mode.json,
    'kotlin' => kotlin_mode.kotlin,
    'makefile' => makefile_mode.makefile,
    'markdown' || 'md' => markdown_mode.markdown,
    'properties' => properties_mode.properties,
    'python' || 'py' => python_mode.python,
    'rust' || 'rs' => rust_mode.rust,
    'scss' => scss_mode.scss,
    'swift' => swift_mode.swift,
    'typescript' || 'ts' || 'tsx' => typescript_mode.typescript,
    'xml' || 'html' => xml_mode.xml,
    'yaml' || 'yml' => yaml_mode.yaml,
    _ => plaintext_mode.plaintext,
  };
}
