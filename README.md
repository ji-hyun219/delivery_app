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
- restaurantDetailProvider 는 restaurantProvider 가 변하면 watch 를 하고 있기 때문에 restaurantDetailProvider 도 다시 빌드된다.

&nbsp;

### 🧐 1월 1일 학습내용

#### Restaurant Detail 캐싱하기

- List 페이지와 상세 페이지 겹치는 정보는 또 불러올 필요 없이 캐시하고 있을 것 (DetailProvider)
- 나머지 아래 상세 정보는 캐시되고 있고, 상세 페이지 다시 들어가면 캐시된 상태에서 API 호출이기 때문에 속도가 빠른 것처럼 보인다.
- 다른 상세를 클릭해도 각각의 상세페이지의 캐시가 기억됨

```dart
// 상세페이지의 initState 부분
ref.read(restaurantProvider.notifier).getDetail(id: widget.id);
```

- restaurantDetailProvider 아님
- `restaurantProvider 가 변경`이 되면 `restaurantDetailProvider 가 다시 빌드`되기 때문이다
- 디테일 화면에 올 때마다 이 코드가 실행된다 (= 상세 정보를 갖고 와라)

&nbsp;

- getDetail 함수 내부는 다음과 같다

```dart
 final pState = state as CursorPagination; // 데이터 존재

    final resp = await repository.getRestaurantDetail(id: id);
    // resp 는 RestaurantDetail Model 임

    // [RestaurantMode(1), RestaurantModel(2), RestaurantModel(3)]
    // id : 2인 친구를 Detail모델을 가져와라
    // getDetail(id: 2);
    // [RestaurantMode(1), RestaurantDetailModel(2), RestaurantModel(3)]
    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>(
            (e) => e.id == id ? resp : e,
          )
          .toList(),
    );
```

&nbsp;

#### Hero 위젯

- tag 값으로 위젯을 연결 애니메이션 효과 (신기..)

```dart
if (heroKey != null)
          Hero(
            tag: ObjectKey(heroKey),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
              child: image,
            ),
          ),
        if (heroKey == null)
          ClipRRect(
            borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
            child: image,
          ),
```

&nbsp;

#### Rating Card UI

- ImageProvider

```
NetworkImage
AssetImage
```

이런 것들은 `ImageProvider` 라고 함

- `CircleAvatar` 는 기본 위젯임
- `...List.generate` (Row 같은 것 안에 풀어놓는 방법)
- `Flexible` 위젯 안에 `Text` 는 줄이 넘어가면 잘리지 않고 다음 줄로 넘어간다는 특성이 있다
