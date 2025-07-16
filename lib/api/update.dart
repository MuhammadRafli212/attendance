import 'dart:convert';
import 'dart:io';

import 'package:attendance/endpoint/endpoint.dart';
import 'package:attendance/model/edit_profil.dart';
import 'package:http/http.dart' as http;

class UpdateProfileService {
  Future<EditProfileResponse> editProfile(
    String token,
    String name,
    String email,
  ) async {
    final response = await http.put(
      Uri.parse(Endpoint.profile),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'name': name, 'email': email},
    );
    if (response.statusCode == 200) {
      return EditProfileResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422) {
      return EditProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update profil. [${response.statusCode}]');
    }
  }

  Future<EditProfilePhotoResponse> editProfilePhoto(
    String token,
    String filePath,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
    final uri = Uri.parse(Endpoint.uploadProfilePhoto);
    final response = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'profile_photo': base64Image}),
    );
    if (response.statusCode == 200) {
      return EditProfilePhotoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update foto profil. [${response.statusCode}]');
    }
  }
}
