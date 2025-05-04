import 'package:flutter/material.dart';
import 'package:coffee/services/api_service.dart';

class RegisterPage1 extends StatefulWidget {
  const RegisterPage1({super.key});

  @override
  State<RegisterPage1> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _apiService.registerUser(
          username: _usernameController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          village: _villageController.text,
          district: _districtController.text,
          province: _provinceController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'ເກີດຂໍ້ຜິດພາດ, ກະລຸນາລອງໃຫມ່';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ເກີດຂໍ້ຜິດພາດ: $e';
        });
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
          content: const Text('ສ້າງໄອດີໃຫມ່ສຳເລັດແລ້ວ'),
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
                      const SizedBox(height: 24),

                      // Error message if present
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Form fields
                      _buildTextField(_usernameController, 'Username',
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ຊື່ຜູ້ໃຊ້';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(_phoneController, 'Phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ເບີໂທ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(_villageController, 'Village',
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ຊື່ບ້ານ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(_districtController, 'District',
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ຊື່ເມືອງ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(_provinceController, 'Province',
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ຊື່ແຂວງ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(_passwordController, 'Password',
                          isPassword: true, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາໃສ່ລະຫັດຜ່ານ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 12),

                      _buildTextField(
                          _confirmPasswordController, 'Confirm Password',
                          isPassword: true, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
                        }
                        if (value != _passwordController.text) {
                          return 'ລະຫັດຜ່ານບໍ່ກົງກັນ';
                        }
                        return null;
                      }),
                      const SizedBox(height: 24),

                      // Register button
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
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create User',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
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