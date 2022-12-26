import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

// Provider
final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, List<RestaurantModel>>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

// Notifier
class RestaurantStateNotifier extends StateNotifier<List<RestaurantModel>> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super([]) {
    paginate();
    // 이렇게 paginate 함수를 넣어주면 이 클래스 StateNotifier 가 생성이 되자마자
    // 페이지네이션을 시작하게 된다
  }

  paginate() async {
    final resp = await repository.paginate();

    state = resp.data;
  }
}
