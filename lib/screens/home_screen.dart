import 'package:flutter/material.dart';
import 'package:re_potential/tabs/about_us_tab.dart';
import 'package:re_potential/tabs/home_tab.dart';
import 'package:re_potential/tabs/map_tab.dart';
import 'package:re_potential/utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  height: 100,
                ),
                SizedBox(
                  width: 350,
                  child: TabBar(
                      indicatorColor: primary,
                      unselectedLabelColor: Colors.grey,
                      labelColor: primary,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                          color: primary, fontFamily: 'Bold', fontSize: 14),
                      tabs: const [
                        Tab(
                          text: 'HOME',
                        ),
                        Tab(
                          text: 'MAP',
                        ),
                        Tab(
                          text: 'ABOUT US',
                        ),
                      ]),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Expanded(
              child: TabBarView(children: [
                HomeTab(),
                MapTab(),
                AboutUsTab(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
