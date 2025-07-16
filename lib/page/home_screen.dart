import 'dart:async';
import 'dart:math';

import 'package:attendance/api/api.dart';
import 'package:attendance/model/history.dart';
import 'package:attendance/model/profil.dart';
import 'package:attendance/page/attendance_history.dart';
import 'package:attendance/page/check_in.dart';
import 'package:attendance/page/check_out.dart';
import 'package:attendance/page/profil.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Data? userProfile;
  double? distance;
  Position? currentPosition;
  final LatLng officeLocation = const LatLng(-6.2066, 106.8169);
  List<Datum> attendanceList = [];
  late Timer timer;
  String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  String greeting = "Welcome";
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    initApp();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        greeting = _getGreeting();
      });
    });
  }

  Future<void> initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      isLoggedIn = true;
      await fetchProfile();
      await getCurrentLocation();
      await fetchAttendance();
    }
    setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good morning";
    if (hour >= 12 && hour < 17) return "Good afternoon";
    if (hour >= 17 && hour < 20) return "Good evening";
    return "Good night";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    final profile = await ApiService.getProfile();
    userProfile = profile?.data;
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final dist = calculateDistance(
      position.latitude,
      position.longitude,
      officeLocation.latitude,
      officeLocation.longitude,
    );

    setState(() {
      currentPosition = position;
      distance = dist;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const earthRadius = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;

  Future<void> fetchAttendance() async {
    final data = await ApiService.getAttendanceHistory();
    setState(() {
      attendanceList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final latest = attendanceList.isNotEmpty ? attendanceList.first : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(greeting),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffA2D5C6), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: initApp,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 10),
                ListTile(
                  title: Text(
                    userProfile?.name ?? 'Nama Pengguna',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    isLoggedIn ? 'Attended' : 'Silakan login terlebih dahulu',
                    style: TextStyle(
                      color: isLoggedIn ? Colors.white70 : Colors.redAccent,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        userProfile?.profilePhotoUrl != null
                            ? NetworkImage(userProfile!.profilePhotoUrl!)
                            : null,
                  ),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Distance from place',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          distance != null
                              ? '${distance!.toStringAsFixed(1)} m'
                              : 'Menghitung...',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentTime,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Jl. Karet Pasar Baru Barat V No.23, Karet Tengsin",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "Check In",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  latest?.checkInTime ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CheckInPage(),
                                      ),
                                    );
                                    if (result == true) fetchAttendance();
                                  },
                                  icon: const Icon(Icons.fingerprint),
                                  color: Colors.green,
                                  tooltip: 'Check In',
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 60,
                              color: Colors.white,
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Check In",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  latest?.checkOutTime ?? '-',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CheckOutPage(),
                                      ),
                                    );
                                    if (result == true) fetchAttendance();
                                  },
                                  icon: const Icon(Icons.fingerprint_outlined),
                                  color: Colors.redAccent,
                                  tooltip: 'Check Out',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Attendance History (7 Days)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AttendanceHistoryPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children:
                        attendanceList.take(5).map((attendance) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEEE',
                                      ).format(attendance.attendanceDate),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(attendance.attendanceDate),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text("Check in"),
                                    Text(attendance.checkInTime ?? '-'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text("Check out"),
                                    Text(attendance.checkOutTime ?? '-'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(color: Colors.black),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA2D5C6),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
        child: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/student.png'),
          radius: 20,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
