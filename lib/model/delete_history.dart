// To parse this JSON data, do
//
//     final deletehistory = deletehistoryFromJson(jsonString);

import 'dart:convert';

Deletehistory deletehistoryFromJson(String str) =>
    Deletehistory.fromJson(json.decode(str));

String deletehistoryToJson(Deletehistory data) => json.encode(data.toJson());

class Deletehistory {
  String message;
  Data data;

  Deletehistory({required this.message, required this.data});

  factory Deletehistory.fromJson(Map<String, dynamic> json) => Deletehistory(
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String id;

  Data({required this.id});

  factory Data.fromJson(Map<String, dynamic> json) => Data(id: json["id"]);

  Map<String, dynamic> toJson() => {"id": id};
}
