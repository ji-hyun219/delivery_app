import 'package:delivery_app/common/dio/dio.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../product/component/product_card.dart';
import '../../restaurant/component/restaurant_card.dart';
import '../../restaurant/model/restaurant_detail_model.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String id;
  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<RestaurantDetailModel> getRestaurantDetail(WidgetRef ref) async {
    final dio = ref.watch(dioProvider);

    final respository = RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return respository.getRestaurantDetail(id: id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: FutureBuilder<RestaurantDetailModel>(
          future: getRestaurantDetail(ref),
          builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // final item = RestaurantDetailModel.fromJson(
            //   json: snapshot.data!,
            // );
            // 위 코드가 필요 없어짐
            // 왜냐, snapshot 에서 바로 모델 되서 나옴

            return CustomScrollView(
              slivers: [
                renderTop(
                  model: snapshot.data!,
                ),
                renderLabel(),
                renderProducts(
                  products: snapshot.data!.products,
                ),
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

  SliverPadding renderProducts({
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index]; // index

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ProductCard.fromModel(model: model),
            );
          },
          childCount: products.length,
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
