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

  void paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    // 추가로 데이터 더 가져오기
    // false - 새로고침 (현재 상태를 덮어 씌움)
    bool forceRefetch = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading
  }) async {
    // 5가지 가능성
    // State 의 상태
    // [상태가]
    // 1) CursorPagination - 정상적으로 데이터가 있는 상태
    // 2) CursorPahinationLoading - 데이터가 로딩 중인 상태 (현재 캐시 없음) (forceRefetch 가 true 인 상태)
    // 3) CursorPaginationError - 에러가 있는 상태
    // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올 때
    // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을 때

    // 바로 반환하는 상황
    // 1) hasMore = false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고있다면)
    // 2) 로딩중 - fetchMore: true
    //    fetchMore가 아닐때 - 새로고침의 의도가 있을 수 있다.
    if (state is CursorPagination && !forceRefetch) {
      // forceRefetch 가 false (ture 이면 강제로 새로고침이 필요한 상태)
      final pState = state as CursorPagination;
      // as 는 무조건 어떤 타입이 들어올 때 써줌
      // 런타임에 공표를 해주는 것

      if (!pState.meta.hasMore) {
        return;
      }
    }

    final isLoading = state is CursorPaginationLoading;
    final isRefetching = state is CursorPaginationRefetching;
    // isRefetching 변수: 데이터가 있는데 유저가 새로고침을 의도한 상태
    final isFetchingMore = state is CursorPaginationFetchingMore;

    // 2번 반환 상황
    if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
      return;
    }
  }
}
