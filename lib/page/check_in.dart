import 'dart:async';

import 'package:attendance/api/preferences.dart';
import 'package:attendance/endpoint/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  Position? currentPosition;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPosition = position;
    });
  }

  Future<void> _checkIn() async {
    if (currentPosition == null) return;

    setState(() {
      isLoading = true;
    });

    final token = await PreferencesHelper.getToken();
    final now = DateTime.now();

    try {
      final response = await http.post(
        Uri.parse(Endpoint.attendanceCheckIn),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          "attendance_date": DateFormat('yyyy-MM-dd').format(now),
          "check_in": DateFormat('HH:mm').format(now),
          "check_in_lat": currentPosition!.latitude.toString(),
          "check_in_lng": currentPosition!.longitude.toString(),
          "check_in_address": "Lokasi saat ini",
          "status": "masuk",
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Check In berhasil")));
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Check In: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check In"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body:
          currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        infoWindow: const InfoWindow(title: "Lokasi Anda"),
                      ),
                    },
                    myLocationEnabled: true,
                  ),
                  Positioned(
                    bottom: 30,
                    left: 30,
                    right: 30,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA2D5C6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                              : const Text(
                                "Check In Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}
