import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../const/data.dart';

class CustomInterceptor extends Interceptor {
  // storage 가져와야 함
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  // 아래 3가지 경우가 함수로 이미 구성되어 있다
  // (1. 요청을 보낼때 2. 응답을 받을 때 3. 에러가 났을 때)

  // 1. 요청을 보낼 때
  // onRequest 에서 헤더를 읽어들일 수 있다 !!!!!!
  // return super.onRequest <-- 여기에서 실제로 요청이 보내진다
  // 그래서 그 전에 위에서 값을 변경할 수 있음 options.header 같은 것..

  // 1. 요청을 보낼때
  // 요청이 보내질때마다
  // 만약에 요청의 Header에 accessToken: true라는 값이 있다면
  // 실제 토큰을 가져와서 (storage에서) authorization: bearer $token으로
  // 헤더를 변경한다.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }
  // 응답을 받을 때
  // 에러가 났을 떄
}
