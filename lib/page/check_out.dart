import 'dart:async';

import 'package:attendance/api/preferences.dart';
import 'package:attendance/endpoint/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
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

  Future<void> _checkOut() async {
    if (currentPosition == null) return;

    setState(() {
      isLoading = true;
    });

    final token = await PreferencesHelper.getToken();
    final now = DateTime.now();

    try {
      final response = await http.post(
        Uri.parse(Endpoint.attendanceCheckOut),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          "attendance_date": DateFormat('yyyy-MM-dd').format(now),
          "check_out": DateFormat('HH:mm').format(now),
          "check_out_lat": currentPosition!.latitude.toString(),
          "check_out_lng": currentPosition!.longitude.toString(),
          "check_out_location":
              "${currentPosition!.latitude}, ${currentPosition!.longitude}",
          "check_out_address": "Lokasi saat ini",
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Check Out berhasil")));
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Check Out: ${response.statusCode}")),
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
        title: const Text("Check Out"),
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
                      onPressed: isLoading ? null : _checkOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Check Out Sekarang",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}
