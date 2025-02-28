import 'package:flutter/material.dart';

import '../widgets/icon_header.dart';
import '../widgets/scrollable_vertical_list.dart';

class EGPA11 extends StatelessWidget {
  const EGPA11({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                actions: [
                  Column(children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                  ]),
                ]),
            body: const Stack(children: [
              ScrollableVerticalList(),
              IconHeader(
                level: 'A1.1',
                subtitle: 'Choose a unit:',
              ),
            ])));
  }
}
