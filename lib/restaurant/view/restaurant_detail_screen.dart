import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletons/skeletons.dart';

import '../../common/const/colors.dart';
import '../../common/layout/default_layout.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/utils/pagination_utils.dart';
import '../../product/component/product_card.dart';
import '../../product/model/product_model.dart';
import '../../rating/component/rating_card.dart';
import '../../rating/model/rating_model.dart';
import '../../restaurant/component/restaurant_card.dart';
import '../../restaurant/model/restaurant_detail_model.dart';
import '../../user/provider/basket_provider.dart';
import '../model/restaurant_model.dart';
import '../provider/restaurant_provider.dart';
import '../provider/restaurant_rating_provider.dart';
import 'basket_screen.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'restaurantDetail';

  final String id;
  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(
        restaurantRatingProvider(widget.id).notifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if (state == null) {
      return const DefaultLayout(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultLayout(
        title: '불타는 떡볶이',
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pushNamed(BasketScreen.routeName);
          },
          backgroundColor: PRIMARY_COLOR,
          child: Badge(
            showBadge: basket.isNotEmpty,
            badgeContent: Text(
              basket
                  .fold<int>(
                    0,
                    (previous, next) => previous + next.count,
                  )
                  .toString(),
              style: const TextStyle(
                color: PRIMARY_COLOR,
                fontSize: 10.0,
              ),
            ),
            badgeColor: Colors.white,
            child: const Icon(
              Icons.shopping_basket_outlined,
            ),
          ),
        ),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            renderTop(
              model: state,
            ),
            if (state is! RestaurantDetailModel) renderLoading(),
            if (state is RestaurantDetailModel) renderLabel(),
            if (state is RestaurantDetailModel)
              renderProducts(
                products: state.products,
                restaurant: state,
              ),
            if (ratingsState is CursorPagination<RatingModel>)
              renderRatings(
                models: ratingsState.data,
              ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: RatingCard(
                  rating: 4,
                  email: 'jc@codefactory.ai',
                  images: [],
                  avatarImage: AssetImage('asset/img/logo/codefactory_logo.png'),
                  content: '맛있습니다.',
                ),
              ),
            ),
          ],
        ));
  }

  SliverPadding renderRatings({
    required List<RatingModel> models,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RatingCard.fromModel(
              model: models[index],
            ),
          ),
          childCount: models.length,
        ),
      ),
    );
  }

  SliverPadding renderLoading() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SkeletonParagraph(
                style: const SkeletonParagraphStyle(
                  lines: 5,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
    required RestaurantModel restaurant,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index]; // index

            return InkWell(
                onTap: () {
                  ref.read(basketProvider.notifier).addToBasket(
                        product: ProductModel(
                          id: model.id,
                          name: model.name,
                          detail: model.detail,
                          imgUrl: model.imgUrl,
                          price: model.price,
                          restaurant: restaurant,
                        ),
                      );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ProductCard.fromModel(
                    model: model,
                  ),
                ));
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantModel model,
  }) {
    return SliverToBoxAdapter(
        child: RestaurantCard.fromModel(
      model: model,
      isDetail: true,
    ));
  }
}
