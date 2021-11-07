import 'package:badi_telemetry/responsive.dart';
import 'package:badi_telemetry/screens/search/components/bt_find_list.dart';
import 'package:badi_telemetry/screens/search/components/header.dart';
import 'package:flutter/material.dart';

import 'package:badi_telemetry/constants.dart';

class Search extends StatelessWidget {//Starting page 
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children:[
                      if (Responsive.isMobile(context))
                        const BtFindList(),
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












/*    
    return SafeArea(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}*/

