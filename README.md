# delivery_app

단순한 배달앱 클론 코딩이 아니라 중급 난이도의 지식을 습득하기 위해 배달앱을 만듭니다

&nbsp;

## 📚 학습 내용

**1) Authentication**  
Refresh Token, Access Token 을 사용한 인증 시스템을 구현해봅니다.
또한 Dio 를 이용해서 자동으로 토큰을 갱신하는 연습을 해봅니다.

**2) Riverpod**  
Riverpod 상태관리 툴에 대해 배워봅니다.

**3) GoRouter**  
라우팅 라이브러리인 GoRouter 에 대해 알아봅니다.

&nbsp;

### 🧐 12월 25일 학습내용

#### dio 에 Provider 적용

- Provider 안에 dio
- 앞으로 Global 하게 쓰일 것들은 Provider 에서 관리..(공통된 값을 참조할 수 있도록!)

```dart
  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(
        storage: storage, // /common/storage 에서 import
      ),
    );

    final repository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(id: id);
  }
```

- 원래는 위의 코드를 계속 화면마다 중복해서 썼었음. 이를 Provider 를 사용해서 개선.

```dart
final dioProvider = Provider((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage: storage),
  );

  return dio;
});
```

- dioProvider 를 생성하고 storageProvider 를 따로 만들어서 `dioProvider 안에 넣어준다` (12월 22일 학습내용 참고)

```dart
  Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
    final dio = ref.watch(dioProvider);

    final respository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return respository.getRestaurantDetail(id: id);
  }
```

- 그리고 위와 같이 화면에 FutureBuilder 를 사용

&nbsp;

#### Repository Provider

- Repository 에도 Provider 사용해보자.
- 나중에 여러 Repository 가 생기면 dio 똑같이 watch 해주면 같은 하나의 dio 를 바라볼 수 있다

```dart
 Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
    final dio = ref.watch(dioProvider);

    final repository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(id: id);
  }
```

- 위는 원래 코드인데 이를 한 줄로 줄여볼 수 있다.

```dart
final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  // 또 다른 레포지토리가 생기면 그에 맞는 제너릭 타입을 넣어주면 된다
  (ref) {
    final dio = ref.watch(dioProvider);

    final repository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository;
  },
);
```

- 먼저 해당 Repository Provider 는 위와 같이 정의를 해주고,

```dart
future: ref.watch(restaurantRepositoryProvider).getRestaurantDetail(
          id: id,
        ),
```

- 첫번째 코드가 아닌, futureBuilder 에서 위와 같이 한 줄로 사용한다

&nbsp;

### 🧐 12월 26일 학습내용

#### StateNotifier 로 캐시 관리

- FutureBuilder 나 StreamBuilder 는 데이터를 한번 불러온 이력이 있으면 캐싱이 되어 있다
- 다른데에서도 캐시를 가져올 수 있을까 (원래는 불가능한데 riverpod 를 이용해서 해보자)
- 직접 캐시를 만들어볼 것이다 (`state notifier` 를 이용해야 함)
- 왜냐 메서드를 많이 만들어서 클래스 안에 집어넣어줄거니까
- state notifier 안에 super 안에 리스트를 넣어주고 위젯에서는 이 상태를 지켜보다가 이 super 값이 변하면 화면에 새로운 값을 렌더링해줄 것이다

```dart
  RestaurantStateNotifier({
    required this.repository,
  }) : super([]) {
    paginate();
    // 이렇게 paginate 함수를 넣어주면 이 클래스 StateNotifier 가 생성이 되자마자
    // 페이지네이션을 시작하게 된다
  }
```

&nbsp;

### 🧐 12월 27일 학습내용

#### CursorPagination 의 abstract class 작성

- 'cursor_pagination_model.dart'
- 계속 `extends` 하는 형태
- refetching => 다시 처음부터 불러오기 (= 새로고침)
- refetching 은 데이터가 있는 상태이니깐 CursorPagination 을 extends 하면 됨
- 근데 extends 하면 CursorPaginationBase 도 extends 한 상태가 되어버린다
- CursorPaginationBase 은 참고로 데이터가 없는 상태 == 로딩이거나 에러인 상태

&nbsp;

#### 쿼리파라미터 추가

- CursorPaginationBase 을 하면 작성한 6 가지의 상태를 활용할 수 있다
- @Quries 값을 붙이면 쿼리 파라미터로 json serialize 된다

```dart
Future<CursorPagination<RestaurantModel>> paginate({
    // 쿼리 파라미터 생성e
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
```

- restaurantProvider 를 반복해서 보자(이해하기 어렵다..) 그리고 쿼리 파라미터 생성한게 다임

&nbsp;

#### 페이지네이션 모델의 여러가지 상태 정의

- fetchMore 가 true 이면, 현재 상태 유지한 상태에서 새로고침
- forceRefetch : 강제로 다시 로딩하기 (데이터 다 지워버리고 새로고침)

```
5가지 가능성
State 의 상태
[상태가]
1) CursorPagination - 정상적으로 데이터가 있는 상태
2) CursorPahinationLoading - 데이터가 로딩 중인 상태 (현재 캐시 없음) (forceRefetch 가 true 인 상태)
3) CursorPaginationError - 에러가 있는 상태
4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올 때
5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을 때
```

&nbsp;

### 🧐 12월 29일 학습내용

#### 페이지네이션 코드에서 바로 반환해야 하는 상황

1. `hasmore = false`

- 즉, 기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면 바로 반환해줘야 함

2. 로딩중 - `fetchMore: true`

- 다음 데이터가 들어오기도 전에 또 요청하면 중복이다, 그걸 방지

&nbsp;

#### 페이지네이션 코드에서 바로 반환 안해줘야 하는 상황

`반환 안해줘야 할 때는`

fetchMore 가 아닐 때 .. 즉 새로고침의 의도가 있을 수 있다. 이때는 페이지네이션 코드를 실행해줘야 함

&nbsp;

```dart
// 페이지네이션일 때
if (state is CursorPagination && !forceRefetch) {
      // forceRefetch 가 false (true 이면 강제로 새로고침이 필요한 상태)
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
```
