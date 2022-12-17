import 'package:delivery_app/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository {
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) = _RestaurantRepository;

  // http://$ip/restaurant/
  // @GET('/')
  // paginate();

  // http://$ip/restaurant/:id
  @GET('/{id}')
  @Headers({
    'authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNjcxMjY0NjE1LCJleHAiOjE2NzEyNjQ5MTV9.cF5rx_ZhKPWm2xTzTCj_1TIKRpIKmyqXGK5F5tl-FNI'
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}



// abstract 클래스 선언했으면 함수는 바디 없어도 됨
// 어떤 함수가 있는자만 선언
// 실제 바디 정의하지 않는다 (어차피 나중에 인스턴스화 해줄거니까)

// 함수는 Future 타입임. 왜냐 API 에서 오니까

