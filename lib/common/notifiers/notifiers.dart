import 'package:flutter/material.dart';

// Image 의 progress bar 전진을 위한 도구

class ProgressNotifier extends ChangeNotifier {
  double progress = 0.0;
  String mid = '';
  void setProgress(double val, String pmid) {
    progress = val;
    mid = pmid;
    notifyListeners();
  }
}

ProgressNotifier? progressHolder;
