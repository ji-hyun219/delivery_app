import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/component/pagination_list_view.dart';
import '../component/restaurant_card.dart';
import '../provider/restaurant_provider.dart';
import 'restaurant_detail_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationListView(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context.goNamed(
              RestaurantDetailScreen.routeName,
              params: {
                'rid': model.id,
              },
            );
          },
          child: RestaurantCard.fromModel(model: model),
        );
      },
    );
  }
}
