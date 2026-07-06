import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'app_menu_models.dart';
import 'privacy_menu_panel.dart';
import 'profile_menu_panel.dart';

class AppMenuOverlay extends StatefulWidget {
  const AppMenuOverlay({
    required this.visible,
    required this.onDismiss,
    super.key,
  });

  final bool visible;
  final VoidCallback onDismiss;

  @override
  State<AppMenuOverlay> createState() => _AppMenuOverlayState();
}

class _AppMenuOverlayState extends State<AppMenuOverlay> {
  static const Duration _transitionDuration = Duration(milliseconds: 320);

  AppMenuPanel _panel = AppMenuPanel.profile;
  MenuProfileState _profile = const MenuProfileState(
    nickname: 'Lin Robot 用户',
    avatarEmoji: '🤖',
  );
  bool _shouldRender = false;
  Timer? _removeTimer;

  @override
  void initState() {
    super.initState();
    _shouldRender = widget.visible;
  }

  @override
  void didUpdateWidget(covariant AppMenuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }

    _removeTimer?.cancel();
    if (widget.visible) {
      setState(() => _shouldRender = true);
      return;
    }

    _removeTimer = Timer(_transitionDuration, () {
      if (mounted && !widget.visible) {
        setState(() => _shouldRender = false);
      }
    });
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldRender) {
      return const SizedBox.shrink();
    }

    final visible = widget.visible;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: _transitionDuration,
              curve: Curves.easeOutCubic,
              child: GestureDetector(
                onTap: widget.onDismiss,
                child: Container(color: Colors.black.withValues(alpha: 0.40)),
              ),
            ),
            AnimatedPositioned(
              top: visible ? 82 : 68,
              left: 18,
              right: 18,
              duration: _transitionDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0.08, -0.06),
                  duration: _transitionDuration,
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    alignment: Alignment.topRight,
                    scale: visible ? 1 : 0.88,
                    duration: _transitionDuration,
                    curve: Curves.easeOutCubic,
                    child: _MenuSheet(
                      panel: _panel,
                      profile: _profile,
                      onDismiss: widget.onDismiss,
                      onPanelChange: (panel) => setState(() => _panel = panel),
                      onProfileChange: (profile) =>
                          setState(() => _profile = profile),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet({
    required this.panel,
    required this.profile,
    required this.onDismiss,
    required this.onPanelChange,
    required this.onProfileChange,
  });

  final AppMenuPanel panel;
  final MenuProfileState profile;
  final VoidCallback onDismiss;
  final ValueChanged<AppMenuPanel> onPanelChange;
  final ValueChanged<MenuProfileState> onProfileChange;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(34),
      elevation: 22,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MenuHeader(onDismiss: onDismiss),
            const SizedBox(height: 20),
            _MenuSegments(panel: panel, onPanelChange: onPanelChange),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.03, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: panel == AppMenuPanel.profile
                  ? ProfileMenuPanel(
                      key: const ValueKey('profile'),
                      profile: profile,
                      onProfileChange: onProfileChange,
                    )
                  : const PrivacyMenuPanel(key: ValueKey('privacy')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '菜单',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '机器人应用设置',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF3F4F0),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onDismiss,
            child: const SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.muted,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuSegments extends StatelessWidget {
  const _MenuSegments({
    required this.panel,
    required this.onPanelChange,
  });

  final AppMenuPanel panel;
  final ValueChanged<AppMenuPanel> onPanelChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MenuSegment(
            text: '个人主页',
            selected: panel == AppMenuPanel.profile,
            onTap: () => onPanelChange(AppMenuPanel.profile),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MenuSegment(
            text: '隐私政策',
            selected: panel == AppMenuPanel.privacy,
            onTap: () => onPanelChange(AppMenuPanel.privacy),
          ),
        ),
      ],
    );
  }
}

class _MenuSegment extends StatelessWidget {
  const _MenuSegment({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.lime : const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
