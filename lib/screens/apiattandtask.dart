import 'dart:io';

import 'package:dio/dio.dart';
import 'globals.dart' as globals;

class ApiAttandTask {
  // Set default configs

  static Future putFile(
    String url,
    File file,
    int taskregid,
    String filename,
  ) async {
    var dio = Dio();
    String fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "DBName": globals.databaseName,
      "UserId": "${globals.userId}",
      "FileName": filename,
      "TaskRegID": "$taskregid"
    });
    var response = await dio.post(url,
        data: formData,
        options: Options(
            method: 'POST',
            responseType: ResponseType.json // or ResponseType.JSON
            ));
    return response;
  }
}
