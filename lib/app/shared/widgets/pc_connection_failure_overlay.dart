// 文件作用：展示连接个人电脑失败时的顶部短提示。

import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PcConnectionFailureOverlay extends StatefulWidget {
  const PcConnectionFailureOverlay({required this.onDismissed, super.key});

  final VoidCallback onDismissed;

  @override
  State<PcConnectionFailureOverlay> createState() =>
      _PcConnectionFailureOverlayState();
}

class _PcConnectionFailureOverlayState
    extends State<PcConnectionFailureOverlay> {
  static const Duration _animationDuration = Duration(milliseconds: 260);
  Timer? _hideTimer;
  Timer? _dismissTimer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() => _visible = true);
      _hideTimer = Timer(const Duration(milliseconds: 1900), _hide);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, -1.35),
              duration: _animationDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: _animationDuration,
                curve: Curves.easeOutCubic,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 260),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_off_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '连接到PC失败',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hide() {
    if (!mounted) {
      return;
    }

    setState(() => _visible = false);
    _dismissTimer = Timer(_animationDuration, widget.onDismissed);
  }
}
