// 文件作用：使用系统安全存储保存 Mota 对话可选 AI，避免 API Key 进入代码或普通配置文件。

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MotaLlmProfile {
  const MotaLlmProfile({
    required this.id,
    required this.modelName,
    required this.apiKey,
  });

  final String id;
  final String modelName;
  final String apiKey;

  bool get isReady => modelName.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  String get maskedApiKey {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      return '未配置';
    }
    if (trimmedKey.length <= 8) {
      return '••••••••';
    }
    return '${trimmedKey.substring(0, 4)}••••${trimmedKey.substring(trimmedKey.length - 4)}';
  }

  Map<String, String> toMetadataJson() {
    return <String, String>{
      'id': id,
      'modelName': modelName,
    };
  }

  static MotaLlmProfile? fromMetadataJson(
    Map<String, dynamic> json,
    String apiKey,
  ) {
    final id = json['id'];
    final modelName = json['modelName'];
    if (id is! String || id.trim().isEmpty) {
      return null;
    }
    if (modelName is! String || modelName.trim().isEmpty) {
      return null;
    }

    return MotaLlmProfile(
      id: id.trim(),
      modelName: modelName.trim(),
      apiKey: apiKey.trim(),
    );
  }
}

class MotaLlmSettingsStore {
  MotaLlmSettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage;

  static const String defaultBaseUrl = 'https://api.openai.com/v1';

  static const String _profilesKey = 'mota_llm_profiles';
  static const String _selectedProfileIdKey = 'mota_llm_selected_profile_id';
  static const String _apiKeyPrefix = 'mota_llm_profile_api_key_';

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  Future<List<MotaLlmProfile>> readProfiles() async {
    final encodedProfiles = await _storage.read(key: _profilesKey);
    if (encodedProfiles == null || encodedProfiles.trim().isEmpty) {
      return <MotaLlmProfile>[];
    }

    final Object? decodedProfiles;
    try {
      decodedProfiles = jsonDecode(encodedProfiles);
    } on FormatException {
      return <MotaLlmProfile>[];
    }

    if (decodedProfiles is! List) {
      return <MotaLlmProfile>[];
    }

    final profiles = <MotaLlmProfile>[];
    for (final item in decodedProfiles) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final id = item['id'];
      if (id is! String || id.trim().isEmpty) {
        continue;
      }

      final apiKey = await _storage.read(key: _apiKeyStorageKey(id));
      final profile = MotaLlmProfile.fromMetadataJson(item, apiKey ?? '');
      if (profile != null) {
        profiles.add(profile);
      }
    }

    return profiles;
  }

  Future<MotaLlmProfile?> readSelectedProfile() async {
    final profiles = await readProfiles();
    if (profiles.isEmpty) {
      return null;
    }

    final selectedId = await _storage.read(key: _selectedProfileIdKey);
    for (final profile in profiles) {
      if (profile.id == selectedId) {
        return profile;
      }
    }

    await selectProfile(profiles.first.id);
    return profiles.first;
  }

  Future<MotaLlmProfile> addProfile({
    required String modelName,
    required String apiKey,
  }) async {
    final profile = MotaLlmProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      modelName: modelName.trim(),
      apiKey: apiKey.trim(),
    );

    final profiles = await readProfiles();
    final updatedProfiles = <MotaLlmProfile>[...profiles, profile];
    await _writeProfilesMetadata(updatedProfiles);
    await _storage.write(
        key: _apiKeyStorageKey(profile.id), value: profile.apiKey);
    await selectProfile(profile.id);
    return profile;
  }

  Future<void> selectProfile(String profileId) {
    return _storage.write(key: _selectedProfileIdKey, value: profileId);
  }

  Future<void> clearAll() async {
    final profiles = await readProfiles();
    await Future.wait<void>([
      for (final profile in profiles)
        _storage.delete(key: _apiKeyStorageKey(profile.id)),
      _storage.delete(key: _profilesKey),
      _storage.delete(key: _selectedProfileIdKey),
    ]);
  }

  Future<void> _writeProfilesMetadata(List<MotaLlmProfile> profiles) {
    final metadata =
        profiles.map((profile) => profile.toMetadataJson()).toList();
    return _storage.write(key: _profilesKey, value: jsonEncode(metadata));
  }

  String _apiKeyStorageKey(String id) {
    return '$_apiKeyPrefix$id';
  }
}
