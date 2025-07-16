import 'package:attendance/api/api.dart';
import 'package:attendance/model/register.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordHidden = true;
  String selectedGender = 'Laki-laki';
  List<Batch> batchList = [];
  List<Training> trainingList = [];
  Batch? selectedBatch;
  Training? selectedTraining;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();

    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    final batches = await ApiService.getBatches();
    final trainings = await ApiService.getTrainings();
    setState(() {
      batchList = batches;
      trainingList = trainings;
      if (batchList.isNotEmpty) selectedBatch = batchList.first;
      if (trainingList.isNotEmpty) selectedTraining = trainingList.first;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (selectedBatch == null || selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih batch dan training terlebih dahulu."),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi sandi tidak cocok.")),
      );
      return;
    }

    final genderCode = selectedGender == 'Laki-laki' ? 'L' : 'P';

    final result = await ApiService.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      batchId: selectedBatch!.id,
      trainingId: selectedTraining!.id,
      jenisKelamin: genderCode,
      passwordConfirmation: confirmPasswordController.text,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pendaftaran berhasil! Silakan login.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Anda Sudah Mendaftar.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Presence App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA2D5C6), Color(0xFF1F1E1E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Register account',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          const SizedBox(height: 24),
                          _buildInput(nameController, 'Nama'),
                          const SizedBox(height: 16),
                          _buildInput(
                            emailController,
                            'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildInput(
                            passwordController,
                            'Kata Sandi',
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInput(
                            confirmPasswordController,
                            'Konfirmasi Sandi',
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown<String>(
                            value: selectedGender,
                            items: ['Laki-laki', 'Perempuan'],
                            onChanged:
                                (val) => setState(() => selectedGender = val!),
                            label: 'Jenis Kelamin',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown<Batch>(
                            value: selectedBatch,
                            items: batchList,
                            onChanged:
                                (val) => setState(() => selectedBatch = val),
                            label: 'Pilih Batch',
                            display: (b) => b.batchKe,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown<Training>(
                            value: selectedTraining,
                            items: trainingList,
                            onChanged:
                                (val) => setState(() => selectedTraining = val),
                            label: 'Pilih Training',
                            display: (t) => t.title,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF578E7E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 115,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '© 2025 Attendance App - All rights reserved.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed:
                      () =>
                          setState(() => isPasswordHidden = !isPasswordHidden),
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String label,
    String Function(T)? display,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items:
          items.map((item) {
            final text = display != null ? display(item) : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(text, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
