import 'package:flutter/material.dart';
import 'package:shared/src/logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> openTalkerScreen(BuildContext context) async {
  await Navigator.push(context, MaterialPageRoute(builder: (context) => TalkerScreen(talker: logger)));
}
