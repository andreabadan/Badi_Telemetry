import 'package:badi_telemetry/controllers/menu_controller.dart';
import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:badi_telemetry/responsive.dart';
import 'package:badi_telemetry/constants.dart';

import 'package:badi_telemetry/screens/00_main/components/side_menu.dart';
import 'package:badi_telemetry/screens/01_search/search_screen.dart';
import 'package:badi_telemetry/screens/02_telemetry/telemetry_screen.dart';
import 'package:badi_telemetry/screens/03_UpdateFirmware/update_firmware.dart';
import 'package:badi_telemetry/screens/04_Graph/graph.dart';
import 'package:badi_telemetry/screens/05_Settings/settings.dart';
import 'package:badi_telemetry/screens/06_Info/info.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceConnectionState bluetoothState = context.watch<BluetoothController>().bluetoothState;
    IndexMenuState indexMenu = context.watch<MenuController>().getIndexMenuState;
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
            if (bluetoothState == DeviceConnectionState.disconnected)
              Expanded(
                // It takes 1/6 part of the screen
                //flex: 1,
                child: _disconnectedWidget(indexMenu),
              ),
            if (bluetoothState == DeviceConnectionState.connected)
              Expanded(
                // It takes 1/6 part of the screen
                //flex: 1,
                child: _connectedWidget(indexMenu),
              ),
            if(bluetoothState == DeviceConnectionState.connecting || bluetoothState == DeviceConnectionState.disconnecting)
              Expanded(
                // It takes 1/6 part of the screen
                //flex: 1,
                child: _bluetoothOperationWidget(indexMenu)
              ),
          ],
        ),
      ),
    );
  }

  Widget _connectedWidget(IndexMenuState indexMenu){
    switch(indexMenu){
      case IndexMenuState.main:
        return const Telemetry();
      case IndexMenuState.updateFirmware:
        return const UpdateFirmware();
      case IndexMenuState.graph:
        return const Graph();
      case IndexMenuState.settings:
        return const Settings();
      case IndexMenuState.info:
        return const Info();
    }
  }

  Widget _disconnectedWidget(IndexMenuState indexMenu){
    switch(indexMenu){
      case IndexMenuState.main:
        return const Search();
      case IndexMenuState.updateFirmware:
        return const UpdateFirmware();
      case IndexMenuState.graph:
        return const Graph();
      case IndexMenuState.settings:
        return const Settings();
      case IndexMenuState.info:
        return const Info();
    }
  }

  Widget _bluetoothOperationWidget(IndexMenuState indexMenu){
    switch(indexMenu){
      case IndexMenuState.main:
        return const SpinKitFadingCircle(
            color: primaryColor,
            size: 70.0,
          );
      case IndexMenuState.updateFirmware:
        return const UpdateFirmware();
      case IndexMenuState.graph:
        return const Graph();
      case IndexMenuState.settings:
        return const Settings();
      case IndexMenuState.info:
        return const Info();
    }
  }

}
