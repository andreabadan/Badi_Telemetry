import 'package:badi_telemetry/controllers/menu_controller.dart';
import 'package:badi_telemetry/responsive.dart';

import 'package:badi_telemetry/screens/00_Main/components/side_menu.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: Consumer<MenuController>(
                  builder: (context, navigationProvider, _) => 
                    navigationProvider.getNavigation),
              ),
          ],
        ),
      ),
    );
  }
}
