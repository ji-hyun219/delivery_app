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

&nbsp;

#### ListView - mapIndexed

```dart
ListView(
  children: images.map(e, index) => null, // dart 에선 불가능
)
```

내가 항상 헤맸던거  
js 는 `index` 를 받아올 수 있지만 dart 는 `불가능`

`extenstion 기능`을 이용해보자.  
import 'package:collection/collection.dart'  
dart 에서 기본 제공임

`mapIndexed`

```dart
  ListView(
      scrollDirection: Axis.horizontal, // 스크롤 좌우인 경우 높이 지정해줘야 함, 수직은 높이 지정 필요 X
      children: images
          .mapIndexed(
            (index, e) => Padding(
              padding: EdgeInsets.only(
                right: index == images.length - 1 ? 0 : 16.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: e,
              ),
            ),
          )
          .toList(), //
```

&nbsp;

#### Rating Card Provider

http://ip/restaurant/:rid/rating

```dart
final restaurantRatingRepositoryProvider = Provider.family<RestaurantRatingRepository, String>((ref, id) {
  final dio = ref.watch(dioProvider);

  return RestaurantRatingRepository(dio, baseUrl: 'http://$ip/restaurant/$id/rating');
});
```

family -> 어떤 `rid 값`인지 받아야 하기 때문  
RestaurantProvider 처럼 `ref` 를 통해 `dio` 가져오고 `baseUrl 지정`해주면 됨

&nbsp;

### 🧐 1월 4일 학습내용

#### 인터페이스를 알아보기

https://ts2ree.tistory.com/314

- 추상 클래스는 클래스간의 공통점이 있을 때 사용되는 것, 인터페이스는 공통점이 없어도 사용가능
- 인터페이스는 일반 메서드 또는 멤버 변수를 가질 수 없다 (추상 클래스는 바디가 있는 일반 메서드 또는 멤버 변수를 가질 수 있다)
- 추상 메서드는 추상 클래스, 인터페이스에 둘다 존재하며 이는 바디가 없고 반드시 오버라이드해서 재정의해야 한다

&nbsp;

#### 페이지네이션 모델 일반화하기

- 문제점: Restaurant Provider 의 paginate 는 Rating Provider 의 긴 함수 paginate 가 똑같이 필요로 한다.(커서페이지네이션 로직 작성한 것..) --> 중복됨
- 해결책: paginate 를 공용으로 쓰는 방법 알아볼 것

&nbsp;

1. `PaginationProvider` 생성한다 (StateNotifier 여야 함)

- 그 후 paginate 함수 복붙

&nbsp;

2. 그러면 각 모델의 repository 부분이 필요하다는 것을 알 수 있다

```dart
class PaginationProvider extends StateNotifier<CursorPaginationBase> {
  final RestaurantRatingRepository repository; // 각 모델의 repository 가 필요하다
  // 여기서는 예시로 RestaurantRatingRepository

  PaginationProvider() : super(CursorPaginationLoading());

  Future<void> paginate({ // ...
```

- 문제점: repository 는 각 모델마다 타입이 다르다
- 해결책: repository 마저 paginate 함수를 일반화해주자

&nbsp;

3. 아래처럼 각 repository 는 타입 빼고 함수가 중복이다

```dart
 Future<CursorPagination<RatingModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
```

&nbsp;

4. 위의 함수를 참고해 아래와 같이 `인터페이스를 생성`해준다  
   (참고로 다트에서 인터페이스가 따로 있지 않지만 클래스를 사용해서 인터페이스처럼 만들어줄 수 있다)

```dart
abstract class IBasePaginationRepository<T> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
```

&nbsp;

5. RestaurantRepository 를 다음과 같이 `implements` 시킴

```dart
abstract class RestaurantRepository implements IBasePaginationRepository<RestaurantModel> {
```

- 인터페이스를 implements 하면 무조건 그 속성이 들어가있다. (여기서 RestaurantRepository 는 paginate 함수가 무조건 포함되어야 한다는 의미)

&nbsp;

6. PaginationProvider 에서 repository 타입을 `IBasePaginationRepository` 로 수정

```dart
class PaginationProvider extends StateNotifier<CursorPaginationBase> {
  final IBasePaginationRepository repository;

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading());

  Future<void> paginate({
```

&nbsp;

7. IBasePaginationRepository 타입이 너무 일반화되어 있는 것을 수정해보자

```dart
class PaginationProvider<U extends IBasePaginationRepository> extends StateNotifier<CursorPaginationBase> {
  final U repository;

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading());

  Future<void> paginate({
```

- U 를 extends 하는 이유: dart 에서는 제너릭에서 implements 라는 키워드를 쓸 수 없다
