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
