import 'package:creta01/constants/styles.dart';
import 'package:creta01/studio/pages/page_manager.dart';
import 'package:creta01/studio/properties/properties_frame.dart';
import 'package:flutter/material.dart';
import '../../common/buttons/basic_button.dart';
import '../../constants/strings.dart';
import '../../model/pages.dart';
import 'property_selector.dart';

// ignore: must_be_immutable
class Settings extends PropertySelector {
  Settings(
    Key? key,
    PageModel? pselectedPage,
    bool pisNarrow,
    bool pisLandscape,
    PropertiesFrameState parent,
  ) : super(
          key: key,
          selectedPage: pselectedPage,
          isNarrow: pisNarrow,
          isLandscape: pisLandscape,
          parent: parent,
        );
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      //mainAxisAlignment: MainAxisAlignment.start,
      //crossAxisAlignment: CrossAxisAlignment.start,
      //controller: _scrollController,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 10, 10),
            child: Text(
              MyStrings.settings,
              style: MyTextStyles.subtitle1,
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 10, 10),
          child: basicButton(
              name: MyStrings.cancel,
              onPressed: () {
                setState(() {
                  pageManagerHolder!.back();
                });
              },
              iconData: Icons.close_outlined),
        ),
      ],
    );
  }
}
