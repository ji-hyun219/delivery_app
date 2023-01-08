import 'package:flutter/material.dart';

import '../../common/component/pagination_list_view.dart';
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
          return ProductCard.fromModel(
            model: model,
            // restaurant: model['restaurant'],
          );
        });
  }
}
