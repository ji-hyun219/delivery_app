import 'package:delivery_app/common/layout/default_layout.dart';
import 'package:delivery_app/common/view/restaurant_screen.dart';
import 'package:flutter/material.dart';

import '../const/colors.dart';

class RootTab extends StatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController _controller;
  int index = 0;

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: 4, vsync: this);
    // vsync 에 현재 StatefulWidget 넣어주면 됨
    // this 는 특정 기능을 갖고 있어야 한다 -> SingleTickerProviderStateMixin

    _controller.addListener(tabListiner); // Listner 따로 빼면 간결해 보임
  }

  void tabListiner() {
    setState(() {
      index = _controller.index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    // 강의에선 _controller.removeListner(tabListner) 를 썼지만
    // controller dispose 하면 수신기도 자동으로 dispose 된다고 함
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: '코팩 딜리버리',
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: PRIMARY_COLOR,
          unselectedItemColor: BODY_TEXT_COLOR,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed, // default: shifting
          onTap: (int index) {
            _controller.animateTo(index);
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood_outlined),
              label: '음식',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: '주문',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: '프로필',
            ),
          ],
        ),
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // 좌우 슬라이드 안되게
          controller: _controller,
          children: const [
            RestaurantScreen(),
            Center(child: Text('음식')),
            Center(child: Text('주문')),
            Center(child: Text('프로필')),
          ],
        ));
  }
}
