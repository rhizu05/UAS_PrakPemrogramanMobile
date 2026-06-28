class ValidationHelper {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat pengiriman wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Alamat pengiriman minimal 10 karakter';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in profile update
    }
    final cleanPhone = value.replaceAll(RegExp(r'\D'), ''); // Numbers only
    if (cleanPhone.length < 9 || cleanPhone.length > 14) {
      return 'Nomor telepon harus terdiri dari 9 hingga 14 angka';
    }
    return null;
  }
}
