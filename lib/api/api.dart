import 'dart:convert';

import 'package:attendance/api/preferences.dart';
import 'package:attendance/endpoint/endpoint.dart';
import 'package:attendance/model/history.dart';
import 'package:attendance/model/login.dart';
import 'package:attendance/model/profil.dart';
import 'package:attendance/model/register.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Register?> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int batchId,
    required int trainingId,
    required String jenisKelamin,
  }) async {
    final url = Uri.parse(Endpoint.register);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          "jenis_kelamin": "L", // Isi dengan L / P
          'password': password,
          'batch_id': batchId,
          'training_id': trainingId,
        }),
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return registerFromJson(response.body);
      }
    } catch (e) {
      print('Register error: $e');
    }
    return null;
  }

  static Future<Login?> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        return loginFromJson(response.body);
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  static Future<Profil?> getProfile() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.profile);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        return profilFromJson(response.body);
      }
    } catch (e) {
      print('Profile error: $e');
    }
    return null;
  }

  static Future<bool> logout() async {
    final url = Uri.parse(Endpoint.logout);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  static Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return true;
      }
    } catch (e) {
      print("Reset Password Error: $e");
    }
    return false;
  }

  static Future<List<Batch>> getBatches() async {
    final url = Uri.parse(Endpoint.batch);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)["data"];
        return List<Batch>.from(data.map((x) => Batch.fromJson(x)));
      }
    } catch (e) {
      print('Batches error: $e');
    }
    return [];
  }

  static Future<List<Training>> getTrainings() async {
    final url = Uri.parse(Endpoint.training);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)["data"];
        return List<Training>.from(data.map((x) => Training.fromJson(x)));
      }
    } catch (e) {
      print('Trainings error: $e');
    }
    return [];
  }

  static Future<bool> checkInAttendance() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.attendanceCheckIn);
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Check-in error: $e');
      return false;
    }
  }

  static Future<bool> checkOutAttendance() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.attendanceCheckOut);
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Check-out error: $e');
      return false;
    }
  }

  static Future<List<Datum>> getAttendanceHistory() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.attendanceHistory);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)["data"];
        return List<Datum>.from(data.map((x) => Datum.fromJson(x)));
      }
    } catch (e) {
      print('History error: $e');
    }
    return [];
  }

  static Future<String?> getAttendanceMap() async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(Endpoint.attendanceMap);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 ? response.body : null;
    } catch (e) {
      print('Attendance map error: $e');
      return null;
    }
  }

  static Future<bool> deleteAttendanceById(int id) async {
    final token = await PreferencesHelper.getToken();
    final url = Uri.parse(
      '${Endpoint.deleteAttendanceHistory}/$id',
    ); // pastikan endpoint kamu pakai /{id}

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Gagal hapus: ${response.body}");
      return false;
    }
  }

  static Future<String> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse(Endpoint.forgotPassword),
      headers: {'Accept': 'application/json'},
      body: {'email': email},
    );
    final jsonData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return jsonData['message'] ?? 'OTP berhasil dikirim ke email';
    } else {
      throw Exception(jsonData['message'] ?? 'Gagal mengirim OTP');
    }
  }
}
