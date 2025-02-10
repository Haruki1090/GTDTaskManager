import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/constants/notion_colors.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

class GlassAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final double blur;
  final double opacity;
  final Color backgroundColor;

  const GlassAppBar({
    super.key,
    // ぼかしの強さ
    this.blur = 5.0,
    // 透明度
    this.opacity = 0.20,
    this.backgroundColor = Colors.white,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(authViewModelProvider);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          title: Text('ALL TASKS',
              style: TextStyle(
                  color: blueColor, fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: backgroundColor.withAlpha((opacity * 255).toInt()),
          elevation: 0,
        ),
      ),
    );
  }
}
