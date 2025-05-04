import 'package:flutter/material.dart';
import 'package:coffee/services/api_restpassword_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPhoneVerified = false;
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // Reset token received from backend after verification
  String _resetToken = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _requestVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາໃສ່ເບີໂທລະສັບ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call API to request verification code
    final response =
        await ApiService.requestVerificationCode(_phoneController.text);

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('ລະຫັດຢືນຢັນໄດ້ຖືກສົ່ງໄປຫາເບີ​ໂທ​ລະ​ສັບ​ຂອງ​ທ່ານ​ແລ້ວ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'ເກີດຂໍ້ຜິດພາດ')),
      );
    }
  }

  void _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາໃສ່ລະຫັດຢືນຢັນ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call API to verify code
    final response = await ApiService.verifyCode(
      _phoneController.text,
      _verificationCodeController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      // Store reset token
      _resetToken = response['resetToken'] ?? '';

      setState(() {
        _isPhoneVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາຕັ້ງລະຫັດຜ່ານໃໝ່')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'ລະຫັດຢືນຢັນບໍ່ຖືກຕ້ອງ')),
      );
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Call API to reset password
      final response = await ApiService.resetPassword(
        _phoneController.text,
        _newPasswordController.text,
        _resetToken,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response['message'] ?? 'ເກີດຂໍ້ຜິດພາດໃນການປ່ຽນລະຫັດຜ່ານ')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ສຳເລັດ'),
          content: const Text('ປ່ຽນລະຫັດຜ່ານສຳເລັດແລ້ວ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login page
                Navigator.of(context).pushReplacementNamed('/intro_page');
              },
              child: const Text('ກັບສູ່ໜ້າ Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE67E22), // Orange background color
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),

                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/bg.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'ລືມລະຫັດຜ່ານ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Phone number field
                      _buildTextField(
                        _phoneController,
                        'ເບີໂທລະສັບ',
                        keyboardType: TextInputType.phone,
                        enabled: !_isPhoneVerified,
                      ),
                      const SizedBox(height: 16),

                      if (!_isPhoneVerified && _resetToken.isEmpty)
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed:
                                _isLoading ? null : _requestVerificationCode,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('ຂໍລະຫັດຢືນຢັນ',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),

                      if (!_isPhoneVerified && _resetToken.isEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          _verificationCodeController,
                          'ລະຫັດຢືນຢັນ',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _isLoading ? null : _verifyCode,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('ຢືນຢັນ',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              _isLoading ? null : _requestVerificationCode,
                          child: const Text(
                            'ສົ່ງລະຫັດອີກຄັ້ງ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],

                      if (_isPhoneVerified) ...[
                        _buildTextField(
                          _newPasswordController,
                          'ລະຫັດຜ່ານໃໝ່',
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ກະລຸນາໃສ່ລະຫັດຜ່ານໃໝ່';
                            }
                            if (value.length < 6) {
                              return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _confirmPasswordController,
                          'ຢືນຢັນລະຫັດຜ່ານໃໝ່',
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານໃໝ່';
                            }
                            if (value != _newPasswordController.text) {
                              return 'ລະຫັດຜ່ານບໍ່ກົງກັນ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _isLoading ? null : _resetPassword,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('ປ່ຽນລະຫັດຜ່ານ',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String placeholder, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: placeholder,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}
