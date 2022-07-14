import 'dart:convert';
import 'package:creta01/common/util/logger.dart';
import 'package:flutter/material.dart';

class CretaConfig {
  static String storageServer = "";

  static Future<void> loadAsset(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/creta_config.json');
    final dynamic jsonMap = jsonDecode(jsonString);
    storageServer = jsonMap['storageServer'];

    logHolder.log('storageServer=$storageServer', level: 5);
  }
}
