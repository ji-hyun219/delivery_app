import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../repository/restaurant_repository.dart';

// Provider
final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

// Notifier
class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  // List<RestaurantModel> 이것을 CursorPagination 으로 교체
  // 왜냐면 CursorPagination 은 meta 에서 hasMore 로 더 있으면 불러오게 하기 위해

  // 2차 수정: CursorPaginationBase 으로 수정
  // 왜냐, CursorPaginationBase 타입은 CursorPagination 타입으로도 extends 가 되어 있기 때문
  // 5가지의 다양한 상태를 활용할 수 있다
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();
    // 이렇게 paginate 함수를 넣어주면 이 클래스 StateNotifier 가 생성이 되자마자
    // 페이지네이션을 시작하게 된다

    // 2차 수정: CursorPaginationLoading()
    // 왜냐, CursorPaginationLoading 은 CursorPaginationBase 타입이면서 데이터의 초기 상태(= 로딩)이기 때문
  }

  paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    // 추가로 데이터 더 가져오기
    // false - 새로고침 (현재 상태를 덮어 씌움)
    bool fetchRefresh = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading
  }) async {
    final resp = await repository.paginate();

    state = resp;
  }
}
