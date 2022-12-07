import 'package:delivery_app/common/component/custom_text_field.dart';
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
      home: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomTextFormField(
            hintText: '이메일을 입력해주세요',
            onChanged: (value) {},
          ),
          CustomTextFormField(
            hintText: '비밀번호를 입력해주세요',
            onChanged: (value) {},
            obscureText: true,
          ),
        ]),
      ),
    );
  }
}
