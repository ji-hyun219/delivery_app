import 'package:delivery_app/common/component/custom_text_field.dart';
import 'package:delivery_app/user/view/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const _App(),
  );
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSans'),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
