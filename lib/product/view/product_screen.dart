import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/component/pagination_list_view.dart';
import '../../restaurant/view/restaurant_detail_screen.dart';
import '../component/product_card.dart';
import '../model/product_model.dart';
import '../provider/product_provider.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
        provider: productProvider,
        itemBuilder: <ProductModel>(_, index, model) {
          return GestureDetector(
            onTap: () {
              context.goNamed(RestaurantDetailScreen.routeName, params: {
                'rid': model.restaurant.id,
              });
            },
            child: ProductCard.fromModel(
              model: model,
            ),
          );
        });
  }
}
