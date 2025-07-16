// To parse this JSON data, do
//
//     final profil = profilFromJson(jsonString);

import 'dart:convert';

Profil profilFromJson(String str) => Profil.fromJson(json.decode(str));

String profilToJson(Profil data) => json.encode(data.toJson());

class Profil {
  String message;
  Data data;

  Profil({required this.message, required this.data});

  factory Profil.fromJson(Map<String, dynamic> json) =>
      Profil(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int? id;
  String? name;
  String? email;
  String? batchKe;
  String? trainingTitle;
  String? jenisKelamin;
  String? profilePhoto;
  String? profilePhotoUrl;

  Data({
    this.id,
    this.name,
    this.email,
    this.batchKe,
    this.trainingTitle,
    this.jenisKelamin,
    this.profilePhoto,
    this.profilePhotoUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    batchKe: json["batch_ke"],
    trainingTitle: json["training_title"],
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_ke": batchKe,
    "training_title": trainingTitle,
    "jenis_kelamin": jenisKelamin,
    "profile_photo_url": profilePhotoUrl,
    "profile_photo": profilePhoto,
  };
}
