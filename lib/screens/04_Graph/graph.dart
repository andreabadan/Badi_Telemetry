import 'package:badi_telemetry/models/header_home.dart';
import 'package:flutter/material.dart';

import 'package:badi_telemetry/constants.dart';


class Graph extends StatelessWidget {
  const Graph({
    Key? key,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
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
                      Text("Graph"),
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