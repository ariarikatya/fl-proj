import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_switch.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> openTalkerScreen(BuildContext context, {required Future<String?> Function() getToken}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TalkerScreen(
        talker: logger,
        isLogsExpanded: false,
        customSettings: [
          CustomSettingsGroup(
            title: 'Customs',
            // enabled: true,
            items: [
              CustomSettingsItemButton(
                name: 'Copy Access Token',
                onTap: () async {
                  final token = await getToken();
                  if (token case String value) {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token copied successfully')));
                    }
                    showSuccessSnackbar('Token copied successfully');
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not get token',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class CustomSettingsItemButton implements CustomSettingsItem<bool> {
  CustomSettingsItemButton({required this.name, required this.onTap}) : value = true;

  final VoidCallback onTap;
  @override
  final String name;
  @override
  bool value;

  @override
  void onChanged(val) => onTap();

  @override
  Widget widgetBuilder(BuildContext context, value, bool isEnabled) => AppSwitch(value: value, onChanged: onChanged);
}
