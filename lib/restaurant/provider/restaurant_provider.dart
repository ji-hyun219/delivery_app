import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../../common/model/pagination_params.dart';
import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

// 기존 문제점
// 디테일 페이지로 가면 계속 로딩바가 나옴
// --> DetailProvider 새로 하나 생성
final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);
  // restaurantProvider 가 변하는지 watch

  if (state is! CursorPagination<RestaurantModel>) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
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
    try {
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
        final pState = state as CursorPagination;

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

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore
      // 데이터를 추가로 더 가져오는 상황
      if (fetchMore) {
        final pState = state as CursorPagination;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약에 데이터가 있는 상황이라면
        // 기존 데이터를 보존한채로 Fetch (API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;

          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 나머지 상황
        else {
          state = CursorPaginationLoading();
        }
      }

      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        // 기존 데이터에
        // 새로운 데이터 추가
        state = resp.copyWith(
          data: [
            ...pState.data,
            ...resp.data,
          ],
        );
      } else {
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
