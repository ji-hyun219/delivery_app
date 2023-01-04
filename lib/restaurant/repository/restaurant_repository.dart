import 'package:delivery_app/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/const/data.dart';
import '../../common/dio/dio.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/model/pagination_params.dart';
import '../../common/respository/base_pagination_repository.dart';
import '../model/restaurant_model.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  // 또 다른 레포지토리가 생기면 그에 맞는 제너릭 타입을 넣어주면 된다
  (ref) {
    final dio = ref.watch(dioProvider);

    final repository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository;
  },
);

@RestApi()
abstract class RestaurantRepository implements IBasePaginationRepository<RestaurantModel> {
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) = _RestaurantRepository;

  // http://$ip/restaurant/
  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate({
    // 쿼리 파라미터 생성
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  // http://$ip/restaurant/:id
  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}



// abstract 클래스 선언했으면 함수는 바디 없어도 됨
// 어떤 함수가 있는자만 선언
// 실제 바디 정의하지 않는다 (어차피 나중에 인스턴스화 해줄거니까)

// 함수는 Future 타입임. 왜냐 API 에서 오니까

