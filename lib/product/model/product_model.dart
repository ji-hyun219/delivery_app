import 'package:delivery_app/restaurant/model/restaurant_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/utils/data_utils.dart';
import '../../restaurant/model/restaurant_model.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends RestaurantProductModel {
  final RestaurantModel restaurant;

  ProductModel({
    required super.id,
    required super.name,
    required super.detail,
    required super.imgUrl,
    required super.price,
    required this.restaurant,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}


// productModel
// id, name, detail, imgUrl, price, restaurant

// restaurantProductModel
// id, name, detail, imgUrl, price