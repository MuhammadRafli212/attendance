import 'dart:convert';

Register registerFromJson(String str) => Register.fromJson(json.decode(str));

String registerToJson(Register data) => json.encode(data.toJson());

class Register {
  final String message;
  final RegisterData data;

  Register({required this.message, required this.data});

  factory Register.fromJson(Map<String, dynamic> json) => Register(
    message: json["message"],
    data: RegisterData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class RegisterData {
  final String token;
  final User user;
  final String? profilePhotoUrl;

  RegisterData({required this.token, required this.user, this.profilePhotoUrl});

  factory RegisterData.fromJson(Map<String, dynamic> json) => RegisterData(
    token: json["token"],
    user: User.fromJson(json["user"]),
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user": user.toJson(),
    "profile_photo_url": profilePhotoUrl,
  };
}

class User {
  final String name;
  final String email;
  final int batchId;
  final int trainingId;
  final String jenisKelamin;
  final String? profilePhoto;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;
  final Batch batch;
  final Training training;

  User({
    required this.name,
    required this.email,
    required this.batchId,
    required this.trainingId,
    required this.jenisKelamin,
    this.profilePhoto,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.batch,
    required this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    email: json["email"],
    batchId: json["batch_id"],
    trainingId: json["training_id"],
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
    batch: Batch.fromJson(json["batch"]),
    training: Training.fromJson(json["training"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "batch_id": batchId,
    "training_id": trainingId,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
    "batch": batch.toJson(),
    "training": training.toJson(),
  };
}

class Batch {
  final int id;
  final String batchKe;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Training {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    participantCount: json["participant_count"],
    standard: json["standard"],
    duration: json["duration"],
    createdAt:
        json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
    updatedAt:
        json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "participant_count": participantCount,
    "standard": standard,
    "duration": duration,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
