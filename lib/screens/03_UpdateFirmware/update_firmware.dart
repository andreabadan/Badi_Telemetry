import 'package:badi_telemetry/models/header_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:badi_telemetry/controllers/bluetooth_controller.dart';

import 'package:badi_telemetry/constants.dart';


class UpdateFirmware extends StatelessWidget {
  const UpdateFirmware({
    Key? key,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    var tachometerData = context.watch<BluetoothController>().tachometerData.version;
    if(tachometerData == "") {
      Provider.of<BluetoothController>(context, listen: false).sendData(checkFirmwareVerion);
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const HeaderHome(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children:[
                      //TODO:UpdateFirmware page
                      Text("Firmware version: " + tachometerData),
                      Text("New firmware version available: 0.1.0B"),
                      InkWell(
                        onTap: () {
                          Provider.of<BluetoothController>(context, listen: false).writeFW();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(defaultPadding * 0.75),
                          margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text("Write new firmware"),
                        ),
                      )
                      //if (!Responsive.isMobile(context))
                      //TODO:Someting if it isn't mobile
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
} 