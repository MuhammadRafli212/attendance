// To parse this JSON data, do
//
//     final checkout = checkoutFromJson(jsonString);

import 'dart:convert';

Checkout checkoutFromJson(String str) => Checkout.fromJson(json.decode(str));

String checkoutToJson(Checkout data) => json.encode(data.toJson());

class Checkout {
  String message;
  Data data;

  Checkout({required this.message, required this.data});

  factory Checkout.fromJson(Map<String, dynamic> json) =>
      Checkout(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  String userId;
  DateTime checkIn;
  String checkInLocation;
  String checkInAddress;
  DateTime checkOut;
  String checkOutLocation;
  String checkOutAddress;
  String status;
  dynamic alasanIzin;
  DateTime createdAt;
  DateTime updatedAt;
  double checkInLat;
  double checkInLng;
  double checkOutLat;
  double checkOutLng;

  Data({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkInLocation,
    required this.checkInAddress,
    required this.checkOut,
    required this.checkOutLocation,
    required this.checkOutAddress,
    required this.status,
    required this.alasanIzin,
    required this.createdAt,
    required this.updatedAt,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkOutLat,
    required this.checkOutLng,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["user_id"],
    checkIn: DateTime.parse(json["check_in"]),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    checkOut: DateTime.parse(json["check_out"]),
    checkOutLocation: json["check_out_location"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "check_in": checkIn.toIso8601String(),
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "check_out": checkOut.toIso8601String(),
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
  };
}
