import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/validation_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/screens/auth/login_screen.dart';
import 'package:uas_prakpemrogramanmobile/widgets/confirmation_dialog.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_button.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_text_field.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.getProfile();
      if (authProvider.user != null) {
        _nameController.text = authProvider.user!.name;
        _phoneController.text = authProvider.user!.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final success = await authProvider.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil Admin berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Konfirmasi Keluar',
        message: 'Apakah Anda yakin ingin keluar dari aplikasi Admin?',
        isDanger: true,
        confirmText: 'Keluar',
        onConfirm: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          
          if (!mounted) return;
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Admin'),
        elevation: 0,
        backgroundColor: AppColors.card,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: authProvider.isLoading && user == null
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Avatar Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.red[50],
                          child: Text(
                            user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'Administrator',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'admin@admin.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ADMINISTRATOR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Update Profile Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubah Informasi Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Nama Lengkap',
                          validator: ValidationHelper.validateName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Nomor Telepon',
                          keyboardType: TextInputType.phone,
                          validator: ValidationHelper.validatePhone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Simpan Perubahan',
                          isLoading: authProvider.isLoading,
                          onPressed: _handleUpdateProfile,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Keluar Akun Admin',
                          isSecondary: true,
                          onPressed: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
