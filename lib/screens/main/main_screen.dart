import 'package:badi_telemetry/controllers/menu_controller.dart';
import 'package:badi_telemetry/responsive.dart';
import 'package:badi_telemetry/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:badi_telemetry/screens/main/components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 1/6 part of the screen
              //flex: 1,
              child: Search(),
            ),
          ],
        ),
      ),
    );
  }
}
