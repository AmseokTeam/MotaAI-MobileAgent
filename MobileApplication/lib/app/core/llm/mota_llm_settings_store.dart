// 文件作用：使用系统安全存储保存 Mota 对话可选 AI，避免 API Key 进入代码或普通配置文件。

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MotaLlmProviderPreset {
  const MotaLlmProviderPreset({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.defaultModelName,
  });

  final String id;
  final String name;
  final String baseUrl;
  final String defaultModelName;

  static const MotaLlmProviderPreset openAi = MotaLlmProviderPreset(
    id: 'openai',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModelName: 'gpt-4o-mini',
  );

  static const MotaLlmProviderPreset kimi = MotaLlmProviderPreset(
    id: 'kimi',
    name: 'Kimi',
    baseUrl: 'https://api.moonshot.cn/v1',
    defaultModelName: 'kimi-k2.6',
  );

  static const MotaLlmProviderPreset deepSeek = MotaLlmProviderPreset(
    id: 'deepseek',
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    defaultModelName: 'deepseek-v4-flash',
  );

  static const MotaLlmProviderPreset custom = MotaLlmProviderPreset(
    id: 'custom',
    name: '自定义',
    baseUrl: '',
    defaultModelName: '',
  );

  static const MotaLlmProviderPreset defaultPreset = kimi;

  static const List<MotaLlmProviderPreset> all = <MotaLlmProviderPreset>[
    openAi,
    kimi,
    deepSeek,
    custom,
  ];

  static MotaLlmProviderPreset byId(String? id) {
    for (final preset in all) {
      if (preset.id == id) {
        return preset;
      }
    }
    return defaultPreset;
  }
}

class MotaLlmProfile {
  const MotaLlmProfile({
    required this.id,
    required this.kind,
    required this.providerId,
    required this.providerName,
    required this.baseUrl,
    required this.modelName,
    required this.apiKey,
  });

  final String id;
  final MotaLlmProfileKind kind;
  final String providerId;
  final String providerName;
  final String baseUrl;
  final String modelName;
  final String apiKey;

  bool get isApi => kind == MotaLlmProfileKind.api;
  bool get isPcBridge => kind == MotaLlmProfileKind.pcBridge;

  bool get isReady {
    if (isPcBridge) {
      return true;
    }
    return baseUrl.trim().isNotEmpty &&
        modelName.trim().isNotEmpty &&
        apiKey.trim().isNotEmpty;
  }

  String get maskedApiKey {
    if (isPcBridge) {
      return '本机 Agent';
    }
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
      'kind': kind.storageId,
      'providerId': providerId,
      'providerName': providerName,
      'baseUrl': baseUrl,
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

    final kind = MotaLlmProfileKind.fromStorageValue(json['kind']);
    if (kind == MotaLlmProfileKind.pcBridge) {
      return MotaLlmProfile(
        id: id.trim(),
        kind: MotaLlmProfileKind.pcBridge,
        providerId: MotaLlmSettingsStore.pcBridgeProviderId,
        providerName: MotaLlmSettingsStore.pcBridgeProviderName,
        baseUrl: '',
        modelName: MotaLlmSettingsStore.pcBridgeModelName,
        apiKey: '',
      );
    }

    if (modelName is! String || modelName.trim().isEmpty) {
      return null;
    }

    final providerId = json['providerId'];
    final preset = MotaLlmProviderPreset.byId(
      providerId is String ? providerId.trim() : null,
    );
    final providerName = json['providerName'];
    final baseUrl = json['baseUrl'];

    final resolvedProviderId =
        providerId is String && providerId.trim().isNotEmpty
            ? providerId.trim()
            : preset.id;
    final resolvedBaseUrl = baseUrl is String && baseUrl.trim().isNotEmpty
        ? baseUrl.trim()
        : preset.baseUrl;

    return MotaLlmProfile(
      id: id.trim(),
      kind: MotaLlmProfileKind.api,
      providerId: resolvedProviderId,
      providerName: providerName is String && providerName.trim().isNotEmpty
          ? providerName.trim()
          : preset.name,
      baseUrl: MotaLlmSettingsStore.normalizeBaseUrl(
        providerId: resolvedProviderId,
        baseUrl: resolvedBaseUrl,
      ),
      modelName: MotaLlmSettingsStore.normalizeModelName(
        providerId: resolvedProviderId,
        modelName: modelName.trim(),
      ),
      apiKey: apiKey.trim(),
    );
  }
}

enum MotaLlmProfileKind {
  api('api'),
  pcBridge('pc_bridge');

  const MotaLlmProfileKind(this.storageId);

  final String storageId;

  static MotaLlmProfileKind fromStorageValue(Object? value) {
    if (value is String) {
      for (final kind in MotaLlmProfileKind.values) {
        if (kind.storageId == value) {
          return kind;
        }
      }
    }
    return MotaLlmProfileKind.api;
  }
}

class MotaLlmSettingsStore {
  MotaLlmSettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage;

  static const String defaultBaseUrl = 'https://api.moonshot.cn/v1';
  static const String defaultModelName = 'kimi-k2.6';
  static const String pcBridgeProfileId = 'pc_bridge_agent';
  static const String pcBridgeProviderId = 'pc_bridge';
  static const String pcBridgeProviderName = '个人电脑 AI Agent';
  static const String pcBridgeModelName = 'MotaLink Agent';

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
    required String providerId,
    required String providerName,
    required String baseUrl,
    required String modelName,
    required String apiKey,
  }) async {
    final profile = MotaLlmProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: MotaLlmProfileKind.api,
      providerId: providerId.trim(),
      providerName: providerName.trim(),
      baseUrl: normalizeBaseUrl(
        providerId: providerId.trim(),
        baseUrl: baseUrl.trim(),
      ),
      modelName: normalizeModelName(
        providerId: providerId.trim(),
        modelName: modelName.trim(),
      ),
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

  Future<MotaLlmProfile> addPcBridgeProfile() async {
    final profile = const MotaLlmProfile(
      id: pcBridgeProfileId,
      kind: MotaLlmProfileKind.pcBridge,
      providerId: pcBridgeProviderId,
      providerName: pcBridgeProviderName,
      baseUrl: '',
      modelName: pcBridgeModelName,
      apiKey: '',
    );

    final profiles = await readProfiles();
    final bridgeIndex = profiles.indexWhere((item) => item.isPcBridge);
    final updatedProfiles = <MotaLlmProfile>[...profiles];
    if (bridgeIndex == -1) {
      updatedProfiles.add(profile);
    } else {
      updatedProfiles[bridgeIndex] = profile;
    }

    await _writeProfilesMetadata(updatedProfiles);
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

  static String normalizeBaseUrl({
    required String providerId,
    required String baseUrl,
  }) {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (providerId == MotaLlmProviderPreset.kimi.id &&
        normalizedBaseUrl == 'https://api.moonshot.cn') {
      return MotaLlmProviderPreset.kimi.baseUrl;
    }
    if (providerId == MotaLlmProviderPreset.deepSeek.id &&
        normalizedBaseUrl == 'https://api.deepseek.com/v1') {
      return MotaLlmProviderPreset.deepSeek.baseUrl;
    }
    return normalizedBaseUrl;
  }

  static String normalizeModelName({
    required String providerId,
    required String modelName,
  }) {
    final normalizedModelName = modelName.trim();
    if (providerId == MotaLlmProviderPreset.kimi.id &&
        normalizedModelName.toLowerCase() == 'kimi') {
      return MotaLlmProviderPreset.kimi.defaultModelName;
    }
    if (providerId == MotaLlmProviderPreset.deepSeek.id &&
        normalizedModelName.toLowerCase() == 'deepseek') {
      return MotaLlmProviderPreset.deepSeek.defaultModelName;
    }
    return normalizedModelName;
  }
}
