import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';
import 'package:gtd_task_manager/views/screens/account_settings_screen.dart';
import 'package:gtd_task_manager/views/screens/settings_screen.dart';

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
    final authVM = ref.read(authViewModelProvider);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AppBar(
          title: Text('ALL TASKS'),
          backgroundColor: backgroundColor.withOpacity(opacity),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.face),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccountSettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authVM.signOut();
                // サインアウト後の遷移は各自実装
              },
            ),
          ],
        ),
      ),
    );
  }
}
