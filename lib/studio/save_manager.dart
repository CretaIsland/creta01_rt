import 'dart:async';
import 'dart:collection';

import 'package:creta01/book_manager.dart';
import 'package:creta01/model/contents.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/cupertino.dart';
import 'package:synchronized/synchronized.dart';

import 'package:creta01/common/util/logger.dart';
import 'package:creta01/db/db_actions.dart';

import '../acc/acc_manager.dart';
import '../constants/strings.dart';
import '../model/models.dart';
import '../model/model_enums.dart';
import '../storage/creta_storage.dart';

SaveManager? saveManagerHolder;

class ProgressState {
  InProgressType progressType = InProgressType.done;
  int fileCount = 0;
  int fileSize = 0;
  double progress = 0;

  ProgressState(this.progressType, {this.fileCount = 0, this.fileSize = 0, this.progress = 0});
}

//자동 저장 , 변경이 있을 때 마다 저장되게 된다.

class SaveManager extends ChangeNotifier {
  static const int savePeriod = 2;
  static const int uploadPeriod = 5;

  final Lock _lock = Lock();
  final Lock _datalock = Lock();
  final Lock _dataCreatedlock = Lock();
  final Lock _contentslock = Lock();
  //final Lock _thumbnaillock = Lock();
  bool _autoSaveFlag = true;
  bool _isContentsUploading = false;

  double _progress = 0;
  int _fileSize = 0;
  //bool _isThumbnailUploading = false;

  String _errMsg = '';
  String get errMsg => _errMsg;

  final Queue<ContentsModel> _contentsChangedQue = Queue<ContentsModel>();
  //final Queue<ContentsModel> _thumbnailChangedQue = Queue<ContentsModel>();
  final Queue<String> _dataChangedQue = Queue<String>();
  final Queue<AbsModel> _dataCreatedQue = Queue<AbsModel>();

  Timer? _saveTimer;
  Timer? _uploadTimer;

  void stopTimer() {
    if (_saveTimer != null) {
      _saveTimer!.cancel();
      _saveTimer = null;
    }
    if (_uploadTimer != null) {
      _uploadTimer!.cancel();
      _uploadTimer = null;
    }
  }

  void shouldBookSave(String mid) {
    if (mid.substring(0, 5) != 'Book=') {
      // book 이 아닌 다른 Row 가 save 된 것인데, 마지막에 Book 의 updateTime 을 한번 바뀌어 줘야 한다.
      if (bookManagerHolder!.defaultBook != null) {
        bookManagerHolder!.defaultBook!.updateTime = DateTime.now();
        _dataChangedQue.add(bookManagerHolder!.defaultBook!.mid);
      }
    }
  }

  Future<void> pushCreated(AbsModel model, String hint) async {
    await _dataCreatedlock.synchronized(() async {
      logHolder.log('created:${model.mid}, via $hint', level: 5);
      _dataCreatedQue.add(model);
      notifyListeners();
      shouldBookSave(model.mid);
    });
  }

  Future<void> pushChanged(String mid, String hint, {bool dontChangeBookTime = false}) async {
    await _datalock.synchronized(() async {
      if (!_dataChangedQue.contains(mid)) {
        logHolder.log('changed:$mid, via $hint', level: 5);
        _dataChangedQue.add(mid);
        notifyListeners();
        if (dontChangeBookTime == false) {
          shouldBookSave(mid);
        }
      }
    });
  }

  Future<void> pushUploadContents(ContentsModel contents) async {
    await _contentslock.synchronized(() async {
      _contentsChangedQue.add(contents);
      notifyListeners();
    });
  }

  // Future<void> _pushUploadThumbnail(ContentsModel contents) async {
  //   await _thumbnaillock.synchronized(() async {
  //     _thumbnailChangedQue.add(contents);
  //     notifyListeners();
  //   });
  // }

  Future<bool> isInSaving() async {
    return await _datalock.synchronized(() async {
      return _dataChangedQue.isNotEmpty && _autoSaveFlag;
    });
  }

  Future<bool> isInSavingCreated() async {
    return await _dataCreatedlock.synchronized(() async {
      return _dataCreatedQue.isNotEmpty && _autoSaveFlag;
    });
  }

  Future<bool> isInContentsUploading() async {
    return await _contentslock.synchronized(() async {
      return _contentsChangedQue.isNotEmpty;
    });
  }

  // Future<bool> isInThumbnailUploding() async {
  //   return await _thumbnaillock.synchronized(() async {
  //     return _thumbnailChangedQue.isNotEmpty;
  //   });
  // }

  Future<ProgressState> getProgress() async {
    if (await isInSaving()) {
      return ProgressState(InProgressType.saving);
    }
    if (await isInSavingCreated()) {
      return ProgressState(InProgressType.saving);
    }
    if (await isInContentsUploading()) {
      return ProgressState(
        InProgressType.contentsUploading,
        fileCount: _contentsChangedQue.length,
        fileSize: _fileSize,
        progress: _progress,
      );
    }
    // if (await isInThumbnailUploding()) {
    //   return InProgressType.thumbnailUploading;
    // }
    return ProgressState(InProgressType.done);
  }

  Future<void> initSaveTimer() async {
    logHolder.log("initSaveTimer", level: 5);
    _saveTimer = Timer.periodic(const Duration(seconds: savePeriod), (timer) async {
      bool autoSave = await _datalock.synchronized<bool>(() async {
        return _autoSaveFlag;
      });
      if (!autoSave) {
        return;
      }
      await _datalock.synchronized(() async {
        if (_dataChangedQue.isNotEmpty) {
          //logHolder.log('autoSave------------start(${_dataChangedQue.length})', level: 1);
          while (_dataChangedQue.isNotEmpty) {
            final mid = _dataChangedQue.first;
            //logHolder.log('autoSave------------', level: 5);
            if (!await DbActions.save(mid)) {
              _errMsg = MyStrings.saveError;
            }
            _dataChangedQue.removeFirst();
          }
          notifyListeners();
          //logHolder.log('autoSave------------end', level: 1);
        }
      });
      await _dataCreatedlock.synchronized(() async {
        if (_dataCreatedQue.isNotEmpty) {
          logHolder.log('autoSaveCreated------------start(${_dataCreatedQue.length})', level: 5);
          while (_dataCreatedQue.isNotEmpty) {
            final model = _dataCreatedQue.first;
            if (!await DbActions.saveModel(model)) {
              _errMsg = MyStrings.saveError;
            }
            _dataCreatedQue.removeFirst();
          }
          notifyListeners();
          logHolder.log('autoSaveCreated------------end', level: 5);
        }
      });
    });
  }

  Future<void> initUploadTimer() async {
    _uploadTimer = Timer.periodic(const Duration(seconds: uploadPeriod), _uploadTimerExpired);
  }

  Future<void> _uploadTimerExpired(Timer timer) async {
    if (_isContentsUploading == true) {
      return;
    }
    await _contentslock.synchronized(() async {
      _errMsg = "";
      if (_contentsChangedQue.isEmpty) {
        _progress = 0;
        _fileSize = 0;
        return;
      }

      // 하나씩 업로드 해야 한다.
      notifyListeners();
      ContentsModel contents = _contentsChangedQue.first;
      logHolder.log('autoUploadContents1------------start', level: 1);
      _isContentsUploading = true;
      CretaStorage server = CretaStorage();
      server.upload(contents, onProgress: (fileSize, progress) {
        _progress = progress;
        _fileSize = fileSize;
        notifyListeners();
        logHolder.log('onProgress------------$_progress, $_fileSize', level: 5);
      }, onComplete: (remoteUrl, thumbnail) {
        contents.remoteUrl = remoteUrl;
        contents.thumbnail = thumbnail;
        logHolder.log('Upload complete ${contents.remoteUrl!}', level: 5);
        logHolder.log('Upload complete ${contents.thumbnail!}', level: 5);
        accManagerHolder!.updateContents(contents);
        pushChanged(contents.mid, 'upload');
        _contentsChangedQue.removeFirst();
        _isContentsUploading = false;
        notifyListeners();
        if (contents.thumbnail != null) {
          bookManagerHolder!.setBookThumbnail(
              contents.thumbnail!, contents.contentsType, contents.aspectRatio.value);
        }
      }, onError: (errMsg) {
        // onError
        _contentsChangedQue.removeFirst();
        _isContentsUploading = false;
        notifyListeners();
        _errMsg = "${MyStrings.uploadError}(${contents.name}) : $errMsg";
        logHolder.log('Upload failed $_errMsg', level: 5);
      });
      logHolder.log('autoUploadContents------------end', level: 1);
    });
  }

  Future<void> blockAutoSave() async {
    await _lock.synchronized(() async {
      //logHolder.log('autoSave locked------------', level: 5);
      _autoSaveFlag = false;
    });
  }

  Future<void> releaseAutoSave() async {
    await _lock.synchronized(() async {
      //logHolder.log('autoSave released------------', level: 5);
      _autoSaveFlag = true;
    });
  }

  Future<bool> isAutoSave() async {
    return await _lock.synchronized(() async {
      return _autoSaveFlag;
    });
  }

  Future<void> delayedReleaseAutoSave(int milliSec) async {
    await Future.delayed(Duration(microseconds: milliSec));
    await _lock.synchronized(() async {
      logHolder.log('autoSave released------------', level: 1);
      _autoSaveFlag = true;
    });
  }

  Future<void> autoSave() async {
    await _lock.synchronized(() async {
      if (_autoSaveFlag) {
        logHolder.log('autoSave------------', level: 5);
        await DbActions.saveAll();
      }
    });
  }
}
