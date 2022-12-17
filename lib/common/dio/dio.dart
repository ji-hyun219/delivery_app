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

  // 1) 요청을 보낼때
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

  // 2) 응답을 받을 때

  // 3) 에러가 났을 떄
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을때 (status code)
    // 토큰을 재발급 받는 시도를하고 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을한다.
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken 아예 없으면
    // 당연히 에러를 던진다
    if (refreshToken == null) {
      // 에러를 던질때는 handler.reject를 사용한다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token'; // 토큰 발급 요청 path

    if (isStatus401 && !isPathRefresh) {
      // 401 인데 RefreshToken 이 잘못되지 않았음 (err.requestOptions 는 에러 보낸 request 정보임)
      // 따라서, 액세스 토큰 갱신해야 함!
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions; // requestOptions == request info

        // 토큰 변경하기
        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        return handler.resolve(response); // 요청이 성공임을 반환
      } on DioError catch (e) {
        // 토큰을 리프레시할 수 있는 상황이 아님 -> 에러
        return handler.reject(e);
      }
    }

    return handler.reject(err); // 그냥 에러가 난 상황임 -> 에러 그대로 반환
  }
}
