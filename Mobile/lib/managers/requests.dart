import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'pictures.dart';

class Post {
  final String userId;
  final Map<String, String> exifInfos;

  Post({@required this.userId, @required this.exifInfos});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        userId: json['userId'],
        exifInfos: json['exifInfos'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    map["exifInfos"] = exifInfos;
    return map;
  }
}

class HttpRequestManager {
  static String _url;
  static final int _port = 5000;
  static final String _path = "/newInfoStolen";

  static setUrl(String baseUrl) {
    _url = baseUrl;
  }

  static Future<bool> createPost(String url,int lPort,String lPath, {Map body}) async {
    HttpClientRequest request = await HttpClient().post(url, lPort, lPath)
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    HttpClientResponse response = await request.close();
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400) {
      // || json == null
      return false; //throw new Exception("Error while fetching data");
    }
    return true;
  }

  static Future<void> sendPicture(Picture picture) async {
    Post newPost = Post(userId: "DumbAssUser", exifInfos: picture.exifInfos);
    print(newPost.exifInfos);
    await createPost(_url,_port,_path, body: newPost.toMap());
  }
}
