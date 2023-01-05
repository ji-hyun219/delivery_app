import 'package:delivery_app/common/provider/pagination_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../../rating/model/rating_model.dart';
import '../repository/restaurant_rating_repository.dart';

final restaurantRatingProvider =
    // id 값이 필요하다 --> StateNotifierProvider.family 사용
    StateNotifierProvider.family<RestaurantRatingStateNotifier, CursorPaginationBase, String>((ref, id) {
  final repo = ref.watch(restaurantRatingRepositoryProvider(id));

  return RestaurantRatingStateNotifier(repository: repo);
});

class RestaurantRatingStateNotifier extends PaginationProvider<RatingModel, RestaurantRatingRepository> {
  RestaurantRatingStateNotifier({
    required super.repository,
  });
}
