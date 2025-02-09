import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass/glass.dart';
import 'package:gtd_task_manager/constants/notion_colors.dart';
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
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'メールアドレスを入力してください';
      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(email)) {
        _emailError = '正しいメールアドレスを入力してください';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'パスワードを入力してください';
      } else if (password.length < 6) {
        _passwordError = 'パスワードは6文字以上で入力してください';
      } else {
        _passwordError = null;
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text("エラー",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: Text(message, style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                  backgroundColor: blueColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
              child: Text("戻る",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submit() async {
    final authViewModel = ref.read(authViewModelProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_emailError != null || _passwordError != null) {
      _showErrorDialog("入力内容を確認してください");
      return;
    }

    try {
      if (_isLogin) {
        await authViewModel.signInWithEmail(email, password);
      } else {
        await authViewModel.registerWithEmail(email, password);
      }
    } catch (e) {
      _showErrorDialog("ログインに失敗しました。\n${e.toString()}");
    }
  }

  @override
  void _signInWithGoogle() async {
    final authViewModel = ref.read(authViewModelProvider);
    try {
      await authViewModel.signInWithGoogle();
    } catch (e) {
      _showErrorDialog("Googleログインに失敗しました。\n${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(100, 163, 163, 163),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: _emailError,
                            errorStyle: TextStyle(color: redColor),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: greyColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: _passwordError,
                            errorStyle: TextStyle(color: redColor),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: greyColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            _isLogin ? 'ログイン' : 'アカウント登録',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? 'アカウントを作成する' : 'ログインに戻る',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: greyColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Googleアカウントでログイン',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ).asGlass(
                    tintColor: Color.fromARGB(255, 115, 115, 115),
                    blurX: 10,
                    blurY: 10,
                    clipBorderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
