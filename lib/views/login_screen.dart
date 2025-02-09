import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtd_task_manager/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final authViewModel = ref.read(authViewModelProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await authViewModel.signInWithEmail(email, password);
      } else {
        await authViewModel.registerWithEmail(email, password);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void _signInWithGoogle() async {
    final authViewModel = ref.read(authViewModelProvider);
    try {
      await authViewModel.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(),
            TextField(),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _submit, child: Text(_isLogin ? 'ログイン' : 'アカウント登録')),
            TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'アカウントを作成する' : 'ログインに戻る')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _signInWithGoogle, child: Text('Googleアカウントでログイン')),
          ],
        ),
      ),
    );
  }
}
