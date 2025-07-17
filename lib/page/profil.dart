import 'package:attendance/api/api.dart';
import 'package:attendance/api/preferences.dart';
import 'package:attendance/model/profil.dart';
import 'package:attendance/page/attendance_history.dart';
import 'package:attendance/page/edit_profil.dart';
import 'package:attendance/page/home_screen.dart';
import 'package:attendance/page/login_screen.dart';
import 'package:attendance/page/reset_password.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Data? user;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null) {
      setState(() {
        user = profile.data;
      });
    }
  }

  Future<void> logout() async {
    await PreferencesHelper.removeToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA2D5C6), Color(0xFFE9B0DF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child:
              user == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              user?.profilePhotoUrl != null
                                  ? NetworkImage(user!.profilePhotoUrl ?? "")
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _infoTile("Batch", user?.batchKe ?? ""),
                        _infoTile("Training", user?.trainingTitle ?? ""),
                        _infoTile("Jenis Kelamin", user?.jenisKelamin ?? ""),

                        const Divider(
                          thickness: 1,
                          height: 32,
                          color: Colors.white,
                        ),
                        _buildMenuItem(
                          icon: Icons.person,
                          text: "Ubah Profil",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(user: user!),
                              ),
                            ).then((value) {
                              if (value != null) fetchProfile();
                            });
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.lock,
                          text: "Ubah Kata Sandi",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResetPasswordPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          thickness: 1,
                          height: 32,
                          color: Colors.white,
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          text: "Keluar",
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: logout,
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffE9B0DF),
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Color(0xFFA2D5C6)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.check_box, color: Color(0xFFA2D5C6)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA2D5C6),
        onPressed: () {},
        child: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/student.png'),
          radius: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
