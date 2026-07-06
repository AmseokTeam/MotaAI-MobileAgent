import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalAsrModelAssets {
  const LocalAsrModelAssets({
    required this.encoderPath,
    required this.decoderPath,
    required this.tokensPath,
    this.modelType = 'paraformer',
    this.sampleRate = 16000,
  });

  final String encoderPath;
  final String decoderPath;
  final String tokensPath;
  final String modelType;
  final int sampleRate;
}

class LocalAsrModelManifest {
  const LocalAsrModelManifest({
    required this.displayName,
    required this.directoryName,
    required this.downloadBaseUrl,
    required this.encoderFilename,
    required this.decoderFilename,
    required this.tokensFilename,
    this.modelType = 'paraformer',
    this.sampleRate = 16000,
  });

  final String displayName;
  final String directoryName;
  final String downloadBaseUrl;
  final String encoderFilename;
  final String decoderFilename;
  final String tokensFilename;
  final String modelType;
  final int sampleRate;

  static const streamingParaformerZhEn = LocalAsrModelManifest(
    displayName: 'Streaming Paraformer zh-en',
    directoryName: 'sherpa-onnx-streaming-paraformer-bilingual-zh-en',
    downloadBaseUrl:
        'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-paraformer-bilingual-zh-en/resolve/main',
    encoderFilename: 'encoder.int8.onnx',
    decoderFilename: 'decoder.int8.onnx',
    tokensFilename: 'tokens.txt',
  );

  List<String> get requiredFilenames => [
        encoderFilename,
        decoderFilename,
        tokensFilename,
      ];

  String get assetDirectory => 'assets/asr_models/$directoryName';

  Future<Directory> installDirectory() async {
    final root = await getApplicationSupportDirectory();
    return Directory(_join(root.path, 'asr_models', directoryName));
  }

  Future<LocalAsrModelAssets> ensureInstalledFromBundledAssets() async {
    final directory = await installDirectory();
    await directory.create(recursive: true);

    for (final filename in requiredFilenames) {
      final target = File(_join(directory.path, filename));
      if (target.existsSync() && target.lengthSync() > 0) {
        continue;
      }

      final data = await rootBundle.load('$assetDirectory/$filename');
      await target.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    return resolveFromDirectory(directory.path);
  }

  Future<LocalAsrModelAssets> resolveInstalledAssets() async {
    final directory = await installDirectory();
    return resolveFromDirectory(directory.path);
  }

  LocalAsrModelAssets resolveFromDirectory(String directoryPath) {
    return LocalAsrModelAssets(
      encoderPath: _join(directoryPath, encoderFilename),
      decoderPath: _join(directoryPath, decoderFilename),
      tokensPath: _join(directoryPath, tokensFilename),
      modelType: modelType,
      sampleRate: sampleRate,
    );
  }

  Future<bool> isInstalled() async {
    final directory = await installDirectory();
    for (final filename in requiredFilenames) {
      if (!File(_join(directory.path, filename)).existsSync()) {
        return false;
      }
    }
    return true;
  }
}

class LocalAsrTranscript {
  const LocalAsrTranscript({required this.text, required this.isFinal});

  final String text;
  final bool isFinal;
}

class LocalAsrStatus {
  const LocalAsrStatus({
    required this.engineName,
    required this.ready,
    required this.detail,
  });

  final String engineName;
  final bool ready;
  final String detail;

  static const sherpaOnnxModelPending = LocalAsrStatus(
    engineName: 'sherpa-onnx',
    ready: false,
    detail: '模型未安装，可用 tools/download_asr_model.sh 下载到本地构建目录',
  );
}

String _join(String first, String second, [String? third]) {
  final buffer = StringBuffer(
    first.endsWith(Platform.pathSeparator)
        ? first.substring(0, first.length - 1)
        : first,
  );
  buffer.write(Platform.pathSeparator);
  buffer.write(second);
  if (third != null) {
    buffer.write(Platform.pathSeparator);
    buffer.write(third);
  }
  return buffer.toString();
}
