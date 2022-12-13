import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../product/component/product_card.dart';
import '../../restaurant/component/restaurant_card.dart';
import '../../restaurant/model/restaurant_detail_model.dart';
import '../const/data.dart';
import '../layout/default_layout.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;
  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<Map<String, dynamic>> getRestaurantDetail() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get(
      'http://$ip/restaurant/$id',
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
    );

    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: '불타는 떡볶이',
        // child: Column(
        //   children: [
        //     RestaurantCard(
        //       image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
        //       name: '불타는 떡볶이',
        //       tags: const ['떡볶이', '맛있음', '치즈'],
        //       ratingsCount: 100,
        //       deliveryTime: 30,
        //       deliveryFee: 3000,
        //       ratings: 4.76,
        //       isDetail: true,
        //       detail: '맛있는 떡볶이',
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 16.0),
        //       child: ProductCard(),
        //     ),
        //   ],
        // ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: getRestaurantDetail(),
          builder: (_, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final item = RestaurantDetailModel.fromJson(
              json: snapshot.data!,
            );

            return CustomScrollView(
              slivers: [
                renderTop(
                  model: item,
                ),
                renderLabel(),
                renderProducts(),
              ],
            );
          },
        ));
  }

  SliverPadding renderLabel() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  SliverPadding renderProducts() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ProductCard(),
            );
          },
          childCount: 10,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantDetailModel model,
  }) {
    return SliverToBoxAdapter(
        child: RestaurantCard.fromModel(
      model: model,
      isDetail: true,
    )
        // RestaurantCard(
        //   image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
        //   name: '불타는 떡볶이',
        //   tags: const ['떡볶이', '맛있음', '치즈'],
        //   ratingsCount: 100,
        //   deliveryTime: 30,
        //   deliveryFee: 3000,
        //   ratings: 4.76,
        //   isDetail: true,
        //   detail: '맛있는 떡볶이',
        // ),
        );
  }
}
