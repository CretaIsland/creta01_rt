// ignore_for_file: avoid_print

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:creta01/common/util/logger.dart';
import 'package:creta01/model/contents.dart';
import '../common/util/config.dart';
import '../studio/studio_main_screen.dart';

class CretaStorage {
  final String nrServerUrl = CretaConfig.storageServer;

  String errMsg = "";
  String remoteUrl = '';
  String thumbnail = '';
  String alreadyExist = 'false';

  void upload(ContentsModel contents,
      {required void Function(int fileSize, double progress) onProgress,
      required void Function(String, String) onComplete,
      required void Function(String errMsg) onError}) {
    logHolder.log('upload', level: 5);
    if (contents.file == null) {
      logHolder.log('file is null', level: 6);
      return;
    }
    _fileUpload(contents.file!, studioMainHolder!.user.id, onProgress, onComplete, onError);
  }

  //파일의 기본 정보를 구하고, Uint8List 형태로 바꾸는 메서드
  void _fileUpload(
      html.File file,
      String userId,
      void Function(int fileSize, double progress) onProgress,
      void Function(String, String) onComplete,
      void Function(String errMsg) onError) {
    //파일 이름 구하기
    String fileName = "${file.size}_${file.name}";
    Uint8List? fileBytes;
    //파일 Uint8List로 변환
    logHolder.log('111111', level: 5);

    html.FileReader reader = html.FileReader();
    //reader.readAsDataUrl(file);

    reader.onLoadEnd.listen((event) async {
      fileBytes = reader.result as Uint8List;
      if (fileBytes == null) {
        errMsg = 'reader failed, Uint8List is null';
        logHolder.log(errMsg, level: 6);
      } else {
        // 파일 분할
        await _chunkFile(userId, fileName, fileBytes!, onProgress);
      }

      if (errMsg.isEmpty && remoteUrl.isNotEmpty && thumbnail.isNotEmpty) {
        onComplete(remoteUrl, thumbnail);
      } else {
        onError(errMsg);
      }
    });
    reader.onError.listen((event) {
      errMsg = event.toString();
      logHolder.log('onError $errMsg', level: 6);
      onError(errMsg);
    });
    reader.readAsArrayBuffer(file);
  }

  // 요청 파라미터에 들어갈 데이터 가공하는 메서드
  Future<void> _chunkFile(
    String userId,
    String fileName,
    Uint8List fileBytes,
    void Function(int fileSize, double progress) onProgress,
  ) async {
    int fileSize = fileBytes.lengthInBytes;
    logHolder.log('_chunkFile($fileSize)', level: 5);
    //파일사이즈가 1MB를 넘는다면 분할 업로드한다.
    double progress = 0;
    const int chunkSize = 10485720;

    if (fileSize <= 1024 * 1024 * 10) {
      if (await _uploadReq(userId, fileName, base64Encode(fileBytes), "0",
          md5.convert(utf8.encode(base64Encode(fileBytes))).toString())) {
        progress = 100;
      }
      onProgress(fileSize, progress);
      return;
    }

    print("이 파일은 10MB 이상입니다.");
    int chunkId = 1;
    int start = 0;
    int end = 0;

    for (int i = 0; i < fileSize; i += chunkSize) {
      // 파일을 1MB씩 분할
      start = i;
      end = start + chunkSize > fileSize ? fileSize : start + chunkSize;
      //분할한 파일을 base64형태로 인코딩
      String stream = base64Encode(fileBytes.sublist(start, end));

      bool checkSuccess = await _uploadReq(userId, fileName, stream, chunkId.toString(),
          md5.convert(utf8.encode(stream)).toString());
      if (checkSuccess == false) {
        onProgress(fileSize, progress); // 실패
        return;
      }
      if (alreadyExist == 'true') {
        logHolder.log("alreadyExist ! $fileName", level: 5);
        onProgress(fileSize, 100);
        break;
      }
      progress = ((i + chunkSize).toDouble() / fileSize.toDouble()) * 100.0;
      progress > 100 ? 100 : progress;
      logHolder.log('progress=$progress', level: 5);
      onProgress(fileSize, progress);
      chunkId += 1;
    }
  }

  //request를 요청하는 메서드
  Future<bool> _uploadReq(
      String userId, String fileName, String stream, String chunkId, String checkSum) async {
    String input =
        '{"userId" : "$userId",  "filename" : "$fileName", "file" : "$stream", "chunkId" : "$chunkId", "checkSum" : "$checkSum" }';

    logHolder.log('$nrServerUrl , $fileName', level: 5);

    try {
      http.Response response = await http.post(
        Uri.parse(nrServerUrl),
        headers: {"Content-type": "application/json"},
        body: input,
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        dynamic retval = jsonDecode(response.body);
        if (retval["error"] != null && retval["error"]!.isNotEmpty) {
          errMsg = retval["error"]!;
          logHolder.log('error !!!! : $errMsg', level: 5);
          return false;
        }
        if (retval["media"] != null && retval["media"]!.isNotEmpty) {
          remoteUrl = retval["media"]!;
        }
        if (retval["thumbnail"] != null && retval["thumbnail"]!.isNotEmpty) {
          thumbnail = retval["thumbnail"]!;
        }
        if (retval["alreadyExist"] != null && retval["alreadyExist"]!.isNotEmpty) {
          alreadyExist = retval["alreadyExist"]!;
        }
        return true;
      }
      errMsg = '${response.statusCode} : ${response.body.toString()}';
    } catch (e) {
      errMsg = e.toString();
    }
    return false;
  }
}
