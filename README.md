# delivery_app

단순한 배달앱 클론 코딩이 아니라 중급 난이도의 지식을 습득하기 위해 배달앱을 만듭니다

&nbsp;

### 🧐 12월 30일 학습내용

#### CursorPaginationFetchingMore 상태 작성

- is 는 클래스의 인스턴스인지 검사
- 코드 계속 보기

```dart
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
    }
```

&nbsp;

#### 완성된 Pagination 로직 실행해보기

- ListView 에서 scrollController 추가
- scrollController.offset: 현재 스크롤 위치를 가져올 수 있음
- scrollController.position.maxScrollExtent : 최대 스크롤 가능 길이
- 바닥 스크롤보다 300 픽셀이 넘어가면 요청 실행

```dart
void scrollListener() {
    // 현재 위치가
    // 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가요청
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      ref.read(restaurantProvider.notifier).paginate(
            fetchMore: true,
          );
    }
  }
```

&nbsp;

#### 캐시관리

- 기존 문제점
- 디테일 페이지로 가면 계속 로딩바가 나옴 --> 해결책: `DetailProvider` 새로 하나 생성

```dart
final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);
  // restaurantProvider 가 변하는지 watch

  if (state is! CursorPagination<RestaurantModel>) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});
```

- state is! CursorPagination 이 부분은 데이터가 없을 경우를 말함. 그래서 null 리턴
