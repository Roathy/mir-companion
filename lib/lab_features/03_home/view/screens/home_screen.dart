import 'package:flutter/material.dart';

import '../widgets/home_appbar.dart';
import '../widgets/vertical_sliver_list.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: "J",
      ),
      body: SafeArea(child: VerticalSliverList()),
    );
  }
}
