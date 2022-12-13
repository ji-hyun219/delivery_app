import 'package:delivery_app/common/const/data.dart';
import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:delivery_app/restaurant/model/restautrant_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'restaurant_detail_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List> paginateRestaurant() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get('http://$ip/restaurant',
        options: Options(headers: {
          'authorization': 'Bearer $accessToken',
        }));

    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List>(
          future: paginateRestaurant(),
          builder: (context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                final item = snapshot.data![index];
                // parsed
                final pItem = RestaurantModel.fromJson(json: item);

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RestaurantDetailScreen(),
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
