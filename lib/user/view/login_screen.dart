import 'dart:convert';
import 'dart:io';

import 'package:delivery_app/common/const/data.dart';
import 'package:delivery_app/common/layout/default_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/component/custom_text_field.dart';
import '../../common/const/colors.dart';
import '../../common/view/root_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    // localhost
    const emulatorIp = '10.0.2.2:3000';
    const simulatorIp = '127.0.0.1:3000';

    final ip = Platform.isIOS ? simulatorIp : emulatorIp;

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _Title(),
              const SizedBox(height: 16),
              const _SubTitle(),
              const SizedBox(height: 16),
              Image.asset(
                'asset/img/misc/logo.png',
                width: MediaQuery.of(context).size.width / 3 * 2, // * 화면의 3/2 사이즈 설정
              ),
              CustomTextFormField(
                hintText: '이메일을 입력해주세요',
                onChanged: (String value) {
                  username = value;
                },
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                hintText: '비밀번호를 입력해주세요',
                onChanged: (String value) {
                  password = value;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // ID:비밀번호
                  final rawString = '$username:$password';

                  Codec<String, String> stringToBase64 = utf8.fuse(base64);

                  String token = stringToBase64.encode(rawString);

                  final resp = await dio.post(
                    'http://$ip/auth/login',
                    options: Options(
                      headers: {
                        'authorization': 'Basic $token', // Basic 은 Raw 형태일 때를 말함
                      },
                    ),
                  );

                  final refreshToken = resp.data['refreshToken'];
                  final accessToken = resp.data['accessToken'];
                  print('refreshToken: $refreshToken');
                  print('accessToekn: $accessToken');

                  const storage = FlutterSecureStorage();

                  await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                  await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RootTab(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                child: const Text(
                  '로그인',
                ),
              ),
              TextButton(
                onPressed: () async {
                  const refreshToken =
                      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3MDYwMDQwMywiZXhwIjoxNjcwNjg2ODAzfQ.npQMRy3X0ur0gtG-h8F7EUzhmQ0Xkg9PxqCsV2S26V0';

                  final resp = await dio.post(
                    'http://$ip/auth/token',
                    options: Options(
                      headers: {
                        'authorization': 'Bearer $refreshToken',
                      },
                    ),
                  );

                  print(resp.data);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  '회원가입',
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다!',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!\n오늘도 성공적인 주문이 되길 :)',
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
