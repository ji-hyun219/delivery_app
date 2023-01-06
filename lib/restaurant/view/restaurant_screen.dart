import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../../common/utils/pagination_utils.dart';
import '../provider/restaurant_provider.dart';
import 'restaurant_detail_screen.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
  }

  void scrollListener() {
    // 현재 위치가
    // 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가요청
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(
        restaurantProvider.notifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(restaurantProvider);
    // restaurantProvider 가 한번 생성이 되면 계속 기억이 된다

    // 완전 처음 로딩일 때
    if (data is CursorPaginationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    // CursorPagination
    // CursorPaginationFetchingMore
    // CursorPaginationRefetching

    final cp = data as CursorPagination; // 이렇게 하면 안되지만 일단 보류

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: controller,
          itemCount: cp.data.length + 1,
          itemBuilder: (_, index) {
            if (index == cp.data.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: data is CursorPaginationFetchingMore
                      ? const CircularProgressIndicator()
                      : const Text('마지막 데이터입니다 ㅠㅠ'),
                ),
              );
            }

            final pItem = cp.data[index];

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
