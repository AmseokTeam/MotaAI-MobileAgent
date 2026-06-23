import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/asr/local_asr_models.dart';
import 'shared/models/companion_connect_state.dart';
import 'pages/home/models/companion_bot_mood.dart';
import 'pages/home/home_page.dart';
import 'pages/creative_workshop/creative_workshop_page.dart';
import 'pages/set/models/robot_settings.dart';
import 'pages/set/set_page.dart';
import 'router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/floating_bottom_bar.dart';
import 'shared/widgets/menu/app_menu_models.dart';

class MiloAiApp extends StatelessWidget
//你知道这里为什么是Class MiloAiApp吗，因为Milo是Mota的亲姐姐
//但是Milo已经未发布就死于胎中，扣111复活Milo，顺带纪念Milo
{
  const MiloAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milo-AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const CompanionRobotApp(),
    );
  }
}

class CompanionRobotApp extends StatefulWidget {
  const CompanionRobotApp({super.key});

  @override
  State<CompanionRobotApp> createState() => _CompanionRobotAppState();
}

class _CompanionRobotAppState extends State<CompanionRobotApp> {
  static const String _nicknameKey = 'menu_profile_nickname';
  static const String _avatarEmojiKey = 'menu_profile_avatar_emoji';
  static const String _avatarImageKey = 'menu_profile_avatar_image';
  static const String _profileBioKey = 'menu_profile_bio';
  static const String _profileTagsKey = 'menu_profile_tags';

  final CompanionBotMood _mood = CompanionBotMood.neutral;
  final CompanionConnectState _connectState =
      CompanionConnectState.disconnected;
  RobotSettings _settings = const RobotSettings();
  MenuProfileState _profile = const MenuProfileState(
    nickname: 'Lin Robot 用户',
    avatarEmoji: '🤖',
  );
  RobotTab _currentTab = RobotTab.chat;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildCurrentPage(),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingBottomBar(
                currentTab: _currentTab,
                onTabChange: (tab) => setState(() => _currentTab = tab),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return switch (_currentTab) {
      RobotTab.chat => RobotHomePage(
          mood: _mood,
        ),
      RobotTab.creativeWorkshop => const CreativeWorkshopPage(),
      RobotTab.settings => RobotSettingsPage(
          connectState: _connectState,
          settings: _settings,
          profile: _profile,
          asrStatus: LocalAsrStatus.sherpaOnnxModelPending,
          onSettingsChanged: _settingsChanged,
          onProfileChanged: _profileChanged,
        ),
    };
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final image = prefs.getString(_avatarImageKey);

    if (!mounted) {
      return;
    }

    setState(() {
      _profile = MenuProfileState(
        nickname: prefs.getString(_nicknameKey) ?? _profile.nickname,
        avatarEmoji: prefs.getString(_avatarEmojiKey) ?? _profile.avatarEmoji,
        bio: prefs.getString(_profileBioKey) ?? _profile.bio,
        preferenceTags:
            prefs.getStringList(_profileTagsKey) ?? _profile.preferenceTags,
        avatarImageBytes: image == null ? null : base64Decode(image),
      );
    });
  }

  Future<void> _profileChanged(MenuProfileState profile) async {
    setState(() => _profile = profile);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, profile.nickname);
    await prefs.setString(_avatarEmojiKey, profile.avatarEmoji);
    await prefs.setString(_profileBioKey, profile.bio);
    await prefs.setStringList(_profileTagsKey, profile.preferenceTags);

    final imageBytes = profile.avatarImageBytes;
    if (imageBytes == null) {
      await prefs.remove(_avatarImageKey);
      return;
    }

    await prefs.setString(_avatarImageKey, base64Encode(imageBytes));
  }

  void _settingsChanged(RobotSettings settings) {
    setState(() => _settings = settings);
  }
}
