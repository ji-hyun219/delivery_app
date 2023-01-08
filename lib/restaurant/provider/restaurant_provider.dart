import 'package:delivery_app/common/provider/pagination_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';
import 'package:collection/collection.dart';

// 기존 문제점
// 디테일 페이지로 가면 계속 로딩바가 나옴
// --> DetailProvider 새로 하나 생성
final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);
  // restaurantProvider 가 변하면 빌드 자동 실행됨 !!!
  // -> 그래서 처음엔 null 이니까 로딩
  // getDetail 호출하면 일치 데이터 있음 == 반환값이 null 이 아님
  // 상세페이지 보여줌

  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhereOrNull((element) => element.id == id);
});

// Provider
final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

// Notifier
class RestaurantStateNotifier extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  // List<RestaurantModel> 이것을 CursorPagination 으로 교체
  // 왜냐면 CursorPagination 은 meta 에서 hasMore 로 더 있으면 불러오게 하기 위해

  // 2차 수정: CursorPaginationBase 으로 수정
  // 왜냐, CursorPaginationBase 타입은 CursorPagination 타입으로도 extends 가 되어 있기 때문
  // 5가지의 다양한 상태를 활용할 수 있다

  RestaurantStateNotifier({required super.repository});

  void getDetail({
    required String id,
  }) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면 (CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await paginate();
    }

    // 위에서 시도해도 데이터가 없는 경우가 있음
    // 즉, state가 CursorPagination이 아닐때 그냥 리턴
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;

    final resp = await repository.getRestaurantDetail(id: id);
    // resp 는 RestaurantDetail Model 임

    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
    // 요청 id: 10
    // list.where((e) => e.id == 10)) 데이터 X
    // 데이터가 없을때는 그냥 캐시의 끝에다가 데이터를 추가해버린다.
    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3),
    // RestaurantDetailModel(10)]
    if (pState.data.where((e) => e.id == id).isEmpty) {
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ],
      );
    } else {
      // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
      // id : 2인 친구를 Detail모델을 가져와라
      // getDetail(id: 2);
      // [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)]
      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>(
              (e) => e.id == id ? resp : e,
            )
            .toList(),
      );
    }
  }
}
