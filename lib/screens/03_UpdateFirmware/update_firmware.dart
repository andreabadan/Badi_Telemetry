import 'package:badi_telemetry/screens/03_UpdateFirmware/components/update_firmware_process.dart';
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
    String tachometerDataFwVers = context.watch<BluetoothController>().tachometerData.version;
    if(tachometerDataFwVers == "") {
      Provider.of<BluetoothController>(context, listen: false).sendCommand(tachometerDataFwVers);
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
                      Text("Firmware version: " + tachometerDataFwVers),
                      //TODO: search new firmware
                      const Text("New firmware version available: 0.1.0B"),
                      const UpdateFirmwareProcess()
                      //if (!Responsive.isMobile(context))
                      //TODO:Someting if it isn't mobile
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 