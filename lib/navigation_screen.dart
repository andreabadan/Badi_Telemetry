import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:badi_telemetry/drawer/drawer_user_controller.dart';
import 'package:badi_telemetry/drawer/home_drawer.dart';

import 'package:badi_telemetry/find_devices.dart';
import 'package:badi_telemetry/dash_board.dart';
import 'package:badi_telemetry/debug_bluetooth.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key, this.device}) : super(key: key);

  final BluetoothDevice? device;

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  Widget screenView = const FindDevicesPage();
  DrawerIndex drawerIndex = DrawerIndex.home;

  @override
  Widget build(BuildContext context) {
    return DrawerUserController(
      screenIndex: drawerIndex,
      drawerWidth: MediaQuery.of(context).size.width * 0.75,
      onDrawerCall: (DrawerIndex drawerIndexdata) {
        changeIndex(drawerIndexdata);
        //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
      },
      screenView: screenView,
      //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.home) {
        if (mounted) {
          setState(() {
            screenView = const FindDevicesPage();
          });
        }
      } else if (drawerIndex == DrawerIndex.help) {
        if (mounted && widget.device != null) {
          setState(() {
            screenView = const DashBoard(device: widget.device!);
          });
        }
      } else if (drawerIndex == DrawerIndex.feedback) {
        if (mounted) {
          setState(() {
            screenView = const DebugScreen();
          });
        }
      } else if (drawerIndex == DrawerIndex.invite) {
        if (mounted) {
          setState(() {
            screenView = const UpdateBoard();
          });
        }
      } else if (drawerIndex == DrawerIndex.about) {
        if (mounted) {
          setState(() {
            screenView = const Settings();
          });
        }
      }
    }
  }
}
