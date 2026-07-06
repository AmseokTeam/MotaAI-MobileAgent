import 'package:flutter/material.dart';

import 'core/agreement/agreement_acceptance_store.dart';
import 'core/llm/mota_llm_settings_store.dart';
import 'core/pc_bridge/pc_bridge_controller.dart';
import 'shared/models/companion_connect_state.dart';
import 'pages/home/models/companion_bot_mood.dart';
import 'pages/home/home_page.dart';
import 'pages/creative_workshop/creative_workshop_page.dart';
import 'pages/set/set_page.dart';
import 'router/app_router.dart';
import 'shared/theme/app_colors.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/agreement_gate_dialog.dart';
import 'shared/widgets/floating_bottom_bar.dart';
import 'shared/widgets/pc_connection_failure_overlay.dart';

class MiloAiApp extends StatelessWidget
//你知道这里为什么是Class MiloAiApp吗，因为Milo是Mota的亲姐姐
//但是Milo已经未发布就死于胎中，扣111复活Milo，顺带纪念Milo
{
  const MiloAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mota',
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
  final AgreementAcceptanceStore _agreementStore =
      const AgreementAcceptanceStore();
  final MotaLlmSettingsStore _llmSettingsStore = MotaLlmSettingsStore();
  final PcBridgeController _bridgeController = PcBridgeController();
  final CompanionBotMood _mood = CompanionBotMood.neutral;
  final CompanionConnectState _connectState =
      CompanionConnectState.disconnected;
  OverlayEntry? _pcConnectionFailureOverlay;
  RobotTab _currentTab = RobotTab.chat;
  bool _agreementDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _checkAgreementAcceptance();
    _initializePcConnection();
  }

  @override
  void dispose() {
    _pcConnectionFailureOverlay?.remove();
    _bridgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTab == RobotTab.chat
          ? AppColors.chatWarmBackground
          : AppColors.pageBackground,
      extendBody: true,
      body: SafeArea(
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: FloatingBottomBar(
        currentTab: _currentTab,
        onTabChange: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return switch (_currentTab) {
      RobotTab.chat => RobotHomePage(
          mood: _mood,
          bridgeController: _bridgeController,
          onPcConnectionFailed: _showPcConnectionFailureNotice,
        ),
      RobotTab.creativeWorkshop => const CreativeWorkshopPage(),
      RobotTab.settings => RobotSettingsPage(
          connectState: _connectState,
        ),
    };
  }

  Future<void> _checkAgreementAcceptance() async {
    final shouldShowGate = await _agreementStore.shouldShowAgreementGate();

    if (!mounted || !shouldShowGate || _agreementDialogVisible) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _agreementDialogVisible) {
        return;
      }

      _showAgreementGate();
    });
  }

  Future<void> _showAgreementGate() async {
    _agreementDialogVisible = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AgreementGateDialog(
          onAccepted: () async {
            await _agreementStore.acceptCurrentAgreement();

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
        );
      },
    );

    _agreementDialogVisible = false;
  }

  Future<void> _initializePcConnection() async {
    try {
      await _llmSettingsStore.clearSelectedProfile();
      final connected = await _bridgeController.connect();
      if (!mounted || connected) {
        return;
      }

      _showPcConnectionFailureNotice();
    } catch (_) {
      if (mounted) {
        _showPcConnectionFailureNotice();
      }
    }
  }

  void _showPcConnectionFailureNotice() {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPcConnectionFailureNotice();
        }
      });
      return;
    }

    _pcConnectionFailureOverlay?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return PcConnectionFailureOverlay(
          onDismissed: () {
            if (_pcConnectionFailureOverlay == entry) {
              _pcConnectionFailureOverlay = null;
            }
            entry.remove();
          },
        );
      },
    );
    _pcConnectionFailureOverlay = entry;
    overlay.insert(entry);
  }
}
