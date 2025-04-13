
import 'package:fluffychat/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainView extends StatefulWidget {

  /// The current state of the parent StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in the [TabBarView].
  final List<Widget> children;

  const MainView({super.key, required this.navigationShell, required this.children});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.navigationShell.currentIndex);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.navigationShell.currentIndex;
  }

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   final selectedColor = Theme.of(context).colorScheme.primary;
  //   const color = Color(0xFFB9B9B9);
  //   return Material(
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: TabBarView(
  //             controller: _tabController,
  //             children: widget.children
  //           ),
  //         ),
  //         TabBar(
  //           controller: _tabController,
  //           tabs: [
  //             Tab(
  //               text: 'Home',
  //               icon: SvgPicture.asset('assets/svg/ic_tab_home.svg', color: _tabController.index == 0 ? selectedColor : color,),
  //             ),
  //             Tab(text: 'Chat', icon: SvgPicture.asset('assets/svg/ic_tab_chat.svg', color: _tabController.index == 1 ? selectedColor : color,),),
  //             Tab(text: 'Call', icon: SvgPicture.asset('assets/svg/ic_tab_call.svg', color: _tabController.index == 2 ? selectedColor : color,),),
  //             Tab(text: 'Setting', icon: SvgPicture.asset('assets/svg/ic_tab_setting.svg', color: _tabController.index == 3 ? selectedColor : color,),),
  //           ],
  //           unselectedLabelColor: color,
  //           labelColor: selectedColor,
  //           indicatorColor: Colors.transparent,
  //           onTap: (index) => widget.navigationShell.goBranch(index),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity, height: double.infinity,
        child: widget.children[widget.navigationShell.currentIndex],
      ),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: const Color(0xFF000000).withOpacity(0.1), height: 1,),
          _buildBottomNavBar()
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: _tabController.index,
      onTap: (index) {
        widget.navigationShell.goBranch(index);
      },
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: const Color(0xFFB9B9B9),
      showUnselectedLabels: true,
      showSelectedLabels: true,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          activeIcon: SvgPicture.asset('assets/svg/ic_tab_home_active.svg'),
          icon: SvgPicture.asset('assets/svg/ic_tab_home.svg'),
          label: "Home",
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          activeIcon: SvgPicture.asset('assets/svg/ic_tab_chat_active.svg'),
          icon: SvgPicture.asset('assets/svg/ic_tab_chat.svg'),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          activeIcon: SvgPicture.asset('assets/svg/ic_tab_payment_active.svg'),
          icon: SvgPicture.asset('assets/svg/ic_tab_payment.svg'),
          label: "Payment",
        ),
      ],
    );
  }
}
