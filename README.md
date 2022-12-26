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

### 🧐 12월 7일 학습내용

#### UI 배치하기

- asset 활용법 -> 폰트 전체적으로 적용 방법
- 똑같은 뷰를 만들어내는 일이 많을 때 DefaultLayout 쓰면 유용 (backgroundColor 같은 것..)
- 이미지를 화면의 3/2 사이즈로 설정하는 방법

#### UI 마무리하기

- SingleChildScrollView > keyboardDismissBehavior : 드래그하면 키보드 닫힘

&nbsp;

### 🧐 12월 9일 학습내용

#### 인증 시스템

- (토큰 vs 세션) https://ts2ree.tistory.com/302
- (JWT 토큰 이론) https://ts2ree.tistory.com/303
- (리프레시 토큰과 액세스 토큰) https://ts2ree.tistory.com/304

&nbsp;

### 🧐 12월 10일 학습내용

#### 탭바 관련

- vsync 에 현재 StatefulWidget 넣어주면 됨. this 는 특정 기능을 갖고 있어야 한다 -> SingleTickerProviderStateMixin

- \_controller.addListener(tabListiner); // Listner 따로 빼면 간결해 보임

#### 레스토랑 카드 관련

- cliprrect : 이미지를 깎는 위젯

```dart
 ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: image,
        ),
```

#### 페이지네이션

- Paged Based Pagination : 요청을 보낼 때 원하는 데이터 갯수와 몇번째 페이지를 가져올 것인지 명시 (=> 몇 번째 페이지느냐에 따라 skip, take 가 이루어짐)
- Cursor Based Pagination : 요청을 보낼 때 마지막 데이터의 기준값(ID) 과 몇개의 데이터를 가지고 올 것인지 명시 (=> 모바일에서 사용하는 방식임. start, perPage)

&nbsp;

### 🧐 12월 11일 학습내용

#### Postman 실습

- `매번 Bearer 토큰 세팅 안해줘도 되는 방법` -> Postman 의 세팅법 배워보기
- Postman 의 environment 에서 accessToken, refreshToken 변수를 만들고 저장
- POST /auth/login 에서 `Tests 탭` 누르기 (이 탭에서는 테스트 코드를 짤 수도 있고 실제 코드를 실행할 수 있다. 여기선 후자)
- 이 탭에 오른쪽에 가이드라인 있으니 그 중 `Set an environmet variable` 눌러보기

```
pm.environment.set("accessToken", pm.response.json().accessToken);
pm.environment.set("refreshToken", pm.response.json().refreshToken);
```

그리고 이렇게 작성하면 된다.  
json() 이건 body 에 접근한다고 생각하면 된다

- GET /restaurant 에서 `Authorization 탭` 누르기
- Type 을 `Bearer Token` 으로 세팅, Token 에다가 `{{accessToken}}` 으로 넣기

&nbsp;

#### 레스토랑 카드 실제 데이터 삽입

```dart
tags: item['tags'] as List<String>
```

이렇게 해도 에러가 나옴

```dart
tags: List<String>.from(item['tags'])
```

이렇게 해야 함

`List.from 메서드`를 보면 아래처럼 기술되어 있다.

```dart
const jsonArray = '''
  [{"text": "foo", "value": 1, "status": true},
   {"text": "bar", "value": 2, "status": false}]
''';
final List<dynamic> dynamicList = jsonDecode(jsonArray);
final List<Map<String, dynamic>> fooData =
    List.from(dynamicList.where((x) => x is Map && x['text'] == 'foo'));
print(fooData);
```

&nbsp;

#### Dart 슈퍼 이니셜라이저

https://ts2ree.tistory.com/305

&nbsp;

#### Dart factory

https://ts2ree.tistory.com/306

&nbsp;

#### firstWhere

https://ts2ree.tistory.com/307

&nbsp;

### 🧐 12월 13일 학습내용

#### isDetail

- final bool isDetail 이렇게 해놓고 this.isdetail = false 하면 상세일 때 true 인자값만 넣어주면 됨
- final String? detail 은 this.detail 로 받아서 상세내용이 없으면 그대로 null 표시하면 됨

&nbsp;

#### path parameter

GET /restaurant/{rid} -> path parameter 는 `:` 로 표현  
예) /restaurant/:rid 이렇게 쓰면 됨

- Image.asset -> 이미지 안 커지면 BoxFit 써야겠다
- 이미지 깎을려면 Cliprrect -> Image.asset
- 가끔 작업할 때 mainAxisAlignment.spaceBetween 등 안먹었던 이유..!: `IntrinsicHeight` -> 이 위젯을 쓰면 내부에 있는 모든 위젯이 최대의 크기를 차지하게 됨! (그래서 최대의 동일한 높이를 가지게 된다)
- 원래 Row 안에 있는 위젯들은 각각 모두 최소의 높이만큼 차지하게 된다.
- 따라서 Row 안에 Column 위젯이 있다면 Column 의 spaceBeween 을 해봤자 안먹는 이유는 바로 이 이유이다. (내용물만큼 높이를 차지하므로 spaceBetween 이 소용없음)

&nbsp;

#### sliverList

- CustomScrollView 안에 일반 위젯 넣을려면 SliverToBoxAdapter 쓰자.
- list 들은 sliverList

&nbsp;

#### 모델이 중복될 경우

extends 사용, 그리고 super 로 전달!!

&nbsp;

### 🧐 12월 14일 학습내용

#### JsonSerializable

- Map<String, dynamic> toJson() => \_$RestaurantModelToJson(this); // this 는 현재 클래스
- @JsonKey -> fromJson 일때 실행하고 싶은 것 넣어주면 됨
- flutter pub run build_runner watch(build 대신) 하면 파일을 계속 바라볼 수 있다. (파일 저장하면 빌드가 자동적으로 된다는 뜻)
- VSCode 자동 완성 기능이 있어서 JsonSerializable 은 파악만 하였음

&nbsp;

### 🧐 12월 17일 학습내용

#### retrofit

- api 요청, 그리고 요청 결과값을 모델로 변환해주는 공통 작업을 retrofit 이라는 패키지로 간소화
- abstract class : 인스턴스화 안되게 선언

#### 토큰 자동 관리하는 방법

- accessToken 이 만료되었을 때(401) 자동으로 리프레시 URL 보내서 다시 accessToken 발급 받아서 다시 재요청하는 로직을 짜는 법을 알아볼 것
- dio 의 interceptor 기능 유용, 이를 사용해볼 것 (onRequest.. 재정의)

```
  아래 3가지 경우가 함수로 이미 구성되어 있다
  1. 요청을 보낼때
  2. 응답을 받을 때
  3. 에러가 났을 때

  1. 요청을 보낼 때
  onRequest 에서 헤더를 읽어들일 수 있다 !!!!!!
  return super.onRequest <-- 여기에서 실제로 요청이 보내진다
  그래서 그 전에 위에서 값을 변경할 수 있음 options.header 같은 것..
```

- 아래 과정을 수행하였음

```
요청이 보내질때마다
  만약에 요청의 Header에 accessToken: true라는 값이 있다면
  실제 토큰을 가져와서 (storage에서) authorization: bearer $token으로
  헤더를 변경한다.
```

#### 에러가 났을 때 핸들링

- Interceptor: 가로챈다. 요청이 보내지기 전에 처리. 즉 `onRequest` 에서 요청이 보내지기 전에 처리한다고 생각하면 됨
- `return super.onRequest(options, handler)` --> 여기에서 실제로 요청이 보내진다. handler 에서 `요청을 보낼지 또는 에러를 생성시킬지 결정`한다.

- handler.reject : 이 메서드를 사용하면 에러를 발생시킬 수 있다
- handler.resolve : 에러 없이 요청을 끝낼 수 있다. 그래서 handler.resolve(response) 에서 response 에서 응답을 받아와서 handler 안에 넣어줘야 한다
- 정리: reject 이용하면 원래대로 에러가 나고 resolve 를 사용해야 함 (에러가 난 상태라도 요청이 성공적임을 반환)
- dio.fetch : 요청 재전송 (원래 우리가 보내려던 요청 == err.requestOptions)

&nbsp;

### 🧐 12월 18일 학습내용

#### 제너릭 T

- 페이지네이션할 때 비슷한 모델이 계속 재사용됨 -> 제너릭으로 확장성있게 사용해보기
- 아래 코드를 이해하자!

```dart
factory CursorPagination.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
```

- T 를 반환하는 함수

&nbsp;

```dart
CursorPagination<T> _$CursorPaginationFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    CursorPagination<T>(
      meta: CursorPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
    );
```

- data 부분을 살펴보자

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
