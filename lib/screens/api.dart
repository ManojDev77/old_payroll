import 'dart:io';

import 'package:dio/dio.dart';
import 'globals.dart' as globals;

class Api {
  // Set default configs

  static Future putFile(String url, File file, String date, String time,
      String lat, String long, String remark, String loc) async {
    var dio = Dio();
    String fileName = file.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "DBName": globals.databaseName,
      "userId": globals.userId,
      "Date": date,
      "Time": time,
      "lat": lat,
      "longitude": long,
      "Remarks": remark,
      "Location": loc,
      "FileName": fileName
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
