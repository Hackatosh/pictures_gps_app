import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pictures.dart';

class Post {
  final String userId;
  final Map<String, String> exifInfos;

  Post({@required this.userId, @required this.exifInfos});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      exifInfos: Map.from(json)..removeWhere((k, v) => k != 'userId')
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["userId"] = userId;
    for(String key in exifInfos.keys){
      map[key] = exifInfos[key];
    }
    return map;
  }
}

class HttpRequestManager{
  static String _url;

  static setUrl(String url){
    _url = url;
  }

  static Future<bool> createPost({Map body}) async {
    return http.post(_url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 ) { // || json == null
        return false; //throw new Exception("Error while fetching data");
      }
      return true;
    });
  }

  static Future<void> sendPicture(Picture picture) async {
    Post newPost = Post(userId:"testUser",exifInfos:picture.exifInfos);
    print(newPost.exifInfos);
    //createPost(body: newPost.toMap());
  }
}
