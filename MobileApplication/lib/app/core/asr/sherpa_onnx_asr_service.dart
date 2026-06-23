import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'local_asr_models.dart';

typedef LocalAsrTranscriptListener = void Function(
  LocalAsrTranscript transcript,
);

class SherpaOnnxAsrService {
  SherpaOnnxAsrService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  sherpa_onnx.OnlineRecognizer? _recognizer;
  sherpa_onnx.OnlineStream? _stream;
  StreamSubscription<List<int>>? _audioSubscription;
  bool _bindingsInitialized = false;
  bool _recording = false;

  bool get isRecording => _recording;

  Future<bool> hasPermission() {
    return _recorder.hasPermission();
  }

  Future<void> start({
    required LocalAsrModelAssets assets,
    required LocalAsrTranscriptListener onTranscript,
  }) async {
    if (_recording) {
      return;
    }

    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission is required for local ASR.');
    }

    _ensureBindingsInitialized();
    _recognizer ??= _createRecognizer(assets);
    _stream ??= _recognizer!.createStream();

    const encoder = AudioEncoder.pcm16bits;
    if (!await _recorder.isEncoderSupported(encoder)) {
      throw StateError('PCM 16-bit recording is not supported on this device.');
    }

    final audioStream = await _recorder.startStream(
      RecordConfig(
        encoder: encoder,
        sampleRate: assets.sampleRate,
        numChannels: 1,
      ),
    );

    _recording = true;
    _audioSubscription = audioStream.listen((data) {
      final recognizer = _recognizer;
      final stream = _stream;
      if (recognizer == null || stream == null) {
        return;
      }

      stream.acceptWaveform(
        samples: _pcm16BytesToFloat32(Uint8List.fromList(data)),
        sampleRate: assets.sampleRate,
      );
      while (recognizer.isReady(stream)) {
        recognizer.decode(stream);
      }

      final result = recognizer.getResult(stream).text.trim();
      if (result.isNotEmpty) {
        onTranscript(
          LocalAsrTranscript(
            text: result,
            isFinal: recognizer.isEndpoint(stream),
          ),
        );
      }

      if (recognizer.isEndpoint(stream)) {
        recognizer.reset(stream);
      }
    });
  }

  Future<void> stop() async {
    if (!_recording) {
      return;
    }

    _recording = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _recorder.stop();
    _stream?.free();
    _stream = _recognizer?.createStream();
  }

  Future<void> dispose() async {
    await stop();
    _stream?.free();
    _stream = null;
    _recognizer?.free();
    _recognizer = null;
    _recorder.dispose();
  }

  void _ensureBindingsInitialized() {
    if (_bindingsInitialized) {
      return;
    }
    sherpa_onnx.initBindings();
    _bindingsInitialized = true;
  }

  sherpa_onnx.OnlineRecognizer _createRecognizer(LocalAsrModelAssets assets) {
    return sherpa_onnx.OnlineRecognizer(
      sherpa_onnx.OnlineRecognizerConfig(
        model: sherpa_onnx.OnlineModelConfig(
          paraformer: sherpa_onnx.OnlineParaformerModelConfig(
            encoder: assets.encoderPath,
            decoder: assets.decoderPath,
          ),
          tokens: assets.tokensPath,
          modelType: assets.modelType,
        ),
        ruleFsts: '',
      ),
    );
  }

  Float32List _pcm16BytesToFloat32(Uint8List bytes) {
    final values = Float32List(bytes.length ~/ 2);
    final data = ByteData.view(bytes.buffer);

    for (var i = 0; i < bytes.length; i += 2) {
      values[i ~/ 2] = data.getInt16(i, Endian.little) / 32768.0;
    }

    return values;
  }
}
