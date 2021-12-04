import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:badi_telemetry/controllers/menu_controller.dart';

import 'package:badi_telemetry/constants.dart';

class SideMenu extends StatelessWidget {

  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceConnectionState bluetoothState = context.watch<MenuController>().deviceConnectionState;
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          if(bluetoothState == DeviceConnectionState.connected || bluetoothState == DeviceConnectionState.connecting)
            DrawerListTile(
              title: "Disconnect",
              svgSrc: "assets/icons/disconnect.svg",
              itemColor: context.watch<BluetoothController>().writing ? itemNotSelectableColor : itemSelectableColor,
              //TODO:??
              press: () {
                if(!context.read<BluetoothController>().writing) {
                  Provider.of<BluetoothController>(context, listen: false).disconnect();
                }
              },
            ),
          if(bluetoothState == DeviceConnectionState.connected)
            DrawerListTile(
              title: "Dashboard",
              svgSrc: "assets/icons/stopwatch.svg",
              itemColor: itemSelectableColor,
              press: () {
                Navigator.of(context).pop();
                Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.telemetry);
              },
            ),
          if(bluetoothState == DeviceConnectionState.connected)
            DrawerListTile(
              title: "Update Firmware",
              svgSrc: "assets/icons/update.svg",
              itemColor: itemSelectableColor,
              press: () {
                Navigator.of(context).pop();
                Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.updateFirmware);
              },
            ),
          if(bluetoothState == DeviceConnectionState.disconnected || bluetoothState == DeviceConnectionState.disconnecting)
            DrawerListTile(
              title: "Connect",
              svgSrc: "assets/icons/connect.svg",
              itemColor: itemSelectableColor,
              press: () {
                Navigator.of(context).pop();
                Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.search);
              },
            ),
          DrawerListTile(
            title: "Graph",
            svgSrc: "assets/icons/graph.svg",
            itemColor: itemSelectableColor,
            press: () {
              Navigator.of(context).pop();
              Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.graph);
            },
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            itemColor: itemSelectableColor,
            press: () {
              Navigator.of(context).pop();
              Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.settings);
            },
          ),
          DrawerListTile(
            title: "Info",
            svgSrc: "assets/icons/info.svg",
            itemColor: itemSelectableColor,
            press: () {
              Navigator.of(context).pop();
              Provider.of<MenuController>(context, listen: false).setIndexMenuState(IndexMenuState.info);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.itemColor,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final Color itemColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: itemColor,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: itemColor),
      ),
    );
  }
}
