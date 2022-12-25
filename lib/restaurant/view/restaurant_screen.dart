import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:delivery_app/restaurant/model/cursor_pagination_model.dart';
import 'package:delivery_app/restaurant/model/restaurant_model.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'restaurant_detail_screen.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<CursorPagination<RestaurantModel>>(
          future: ref.watch(restaurantRepositoryProvider).paginate(),
          builder: (context, AsyncSnapshot<CursorPagination<RestaurantModel>> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return ListView.separated(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (_, index) {
                final pItem = snapshot.data!.data[index];

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(id: pItem.id),
                        ),
                      );
                    },
                    child: RestaurantCard.fromModel(model: pItem)); // RestaurantCard 위젯의 factory 생성자
              },
              separatorBuilder: (_, index) {
                return const SizedBox(height: 16.0);
              },
            );
          },
        ),
      ),
    );
  }
}
