import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:delivery_app/restaurant/model/cursor_pagination_model.dart';
import 'package:delivery_app/restaurant/model/restaurant_model.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/restaurant_provider.dart';
import 'restaurant_detail_screen.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(restaurantProvider);
    // restaurantProvider 가 한번 생성이 되면 계속 기억이 된다

    if (data.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          itemCount: data.length,
          itemBuilder: (_, index) {
            final pItem = data[index];

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(
                      id: pItem.id,
                    ),
                  ),
                );
              },
              child: RestaurantCard.fromModel(
                model: pItem,
              ),
            );
          },
          separatorBuilder: (_, index) {
            return const SizedBox(height: 16.0);
          },
        ));
  }
}
