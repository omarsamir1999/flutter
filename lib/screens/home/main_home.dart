import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../components/bottom_bar_custom.dart';
import '../../constants/colors.dart';
import '../order_page.dart';
import '../profile_screen.dart';
import 'cart_screnss/cart_page.dart';
import 'home_screens/home_screen.dart';
import 'menu_page.dart';

// ignore: must_be_immutable
class UserDashboard extends StatefulWidget {
  static const String id = '/user-dashboard';
  UserDashboard({
    Key? key,
    this.child,
  }) : super(key: key);
  Widget? child;
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool isCollapsed = true;
  late double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: duration);

    _scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(_controller);

    super.initState();
    widget.child ??= MainScreen(
      child: Container(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      if (isCollapsed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.customGrey,
      body: !isCollapsed
          ? SafeArea(
              child: Stack(
                children: <Widget>[
                  Dashboard(
                    duration: duration,
                    isCollapsed: isCollapsed,
                    scaleAnimation: _scaleAnimation,
                    toggleDrawer: toggleDrawer,
                    child: widget.child == null
                        ? MainScreen(child: Container())
                        : widget.child!,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Dashboard(
                  duration: duration,
                  isCollapsed: isCollapsed,
                  scaleAnimation: _scaleAnimation,
                  toggleDrawer: toggleDrawer,
                  child: widget.child == null
                      ? MainScreen(child: Container())
                      : widget.child!,
                ),
              ],
            ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 180,
      child: Divider(
        color: Colors.white,
        height: 25,
        thickness: 0.5,
        indent: 48,
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard(
      {Key? key,
      required this.duration,
      required this.child,
      required this.isCollapsed,
      required this.scaleAnimation,
      required this.toggleDrawer})
      : super(key: key);
  final Duration duration;
  final bool isCollapsed;
  final Animation<double> scaleAnimation;
  final Widget child;
  final Function() toggleDrawer;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    double screenWidth, screenHeight;
    screenHeight = size.height;
    screenWidth = size.width;
    return AnimatedPositioned(
        duration: widget.duration,
        top: 0,
        bottom: 0,
        left: widget.isCollapsed ? 0 : 0.5 * screenWidth,
        right: widget.isCollapsed ? 0 : -0.5 * screenWidth,
        child: ScaleTransition(
          scale: widget.scaleAnimation,
          child: widget.isCollapsed
              ? Stack(children: [
                  // ignore: unnecessary_null_comparison
                  (widget.child == null)
                      ? MainScreen(
                          child: Container(),
                        )
                      : widget.child,
                  SizedBox(
                    width: 15,
                    child: GestureDetector(),
                  )
                ])
              : Stack(children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        double.infinity.widthBox,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            16.widthBox,
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onPressed: () {
                                setState(() {
                                  widget.toggleDrawer();
                                });
                              },
                              highlightColor: CustomColors.customGrey,
                              child: Text(
                                'Back to browsing',
                                style: dashboardButtonText,
                              ),
                            ),
                          ],
                        ),
                        16.heightBox,
                      ],
                    ),
                  ),
                  Material(
                    elevation: 2,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.child),
                  ).pOnly(left: 12, bottom: 70),
                ]),
        ));
  }
}

TextStyle dashboardButtonText = const TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white);

class MainScreen extends StatefulWidget {
  static const String id = '/homescreen';
  const MainScreen({Key? key, required this.child, this.toggleDrawer})
      : super(key: key);

  final Widget child;
  final Function()? toggleDrawer;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPage = 2;
  late List<Widget> _pages;

  updateCurrentPage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  @override
  void initState() {
    _pages = [
      const MenuPage(),
      const OrderPage(),
      const HomeScreen(),
      const CartScreen(),
      const AccountPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentPage]),
      bottomNavigationBar: CustomNavigationBar(
        updatePage: updateCurrentPage,
        currentHomeScreen: _currentPage,
      ),
    );
  }
}
