import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking/models/user_model.dart';
import 'package:hotel_booking/auth/login.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception("No Firebase ID Token");

      final profileData = {
        'id': user.uid,
        'email': user.email,
        'role': 'user',
        'canEdit': true,
        'canDelete': false,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': '',
        'profileImage': '',
      };

      final response = await http.post(
        Uri.parse(
          "https://flutter-hotel-booking-api-2.onrender.com/api/users/register",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: json.encode(profileData),
      );

      final resBody = json.decode(response.body);

      if (response.statusCode == 201) {
        final userData = resBody['user'];
        final newUser = userData != null
            ? UserModel.fromJson(userData)
            : UserModel(
                id: user.uid,
                email: user.email!,
                role: 'user',
                canEdit: true,
                canDelete: false,
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                phone: '',
                profileImage: '',
              );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(newUser.toJson()));
        await prefs.setString('email', newUser.email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("បានចុះឈ្មោះដោយជោគជ័យ!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "ការចុះឈ្មោះបរាជ័យ: ${resBody['error'] ?? 'កំហុសមិនស្គាល់'}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      var msg = "ការចុះឈ្មោះបរាជ័យ។";
      if (e.code == 'email-already-in-use')
        msg = "អ៊ីមែលនេះត្រូវបានប្រើរួចហើយ។";
      if (e.code == 'weak-password') msg = "ពាក្យសម្ងាត់ខ្សោយពេក។";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("មានកំហុស: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColor.labelColor),
        filled: true,
        fillColor: AppColor.appBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: AppColor.textColor),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool visible,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.labelColor),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: AppColor.labelColor,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: AppColor.appBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: AppColor.textColor),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        title: Text(
          "ចុះឈ្មោះ",
          style: TextStyle(color: AppColor.textColor, fontSize: 18),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "បង្កើតគណនីរបស់អ្នក",
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _firstNameController,
                  label: "នាមខ្លួន",
                  hint: "បញ្ចូលនាមខ្លួន",
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'សូមបញ្ចូលនាមខ្លួន' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _lastNameController,
                  label: "នាមត្រកូល",
                  hint: "បញ្ចូលនាមត្រកូល",
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'សូមបញ្ចូលនាមត្រកូល' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: "អ៊ីមែល",
                  hint: "បញ្ចូលអ៊ីមែល",
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'សូមបញ្ចូលអ៊ីមែល';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'អ៊ីមែលមិនត្រឹមត្រូវ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _passwordController,
                  label: "ពាក្យសម្ងាត់",
                  hint: "បញ្ចូលពាក្យសម្ងាត់",
                  visible: _isPasswordVisible,
                  toggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                    if (v.length < 6) return 'ត្រូវតែមានយ៉ាងហោចណាស់ ៦ តួអក្សរ';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: "បញ្ជាក់ពាក្យសម្ងាត់",
                  hint: "បញ្ចូលម្ដងទៀត",
                  visible: _isConfirmPasswordVisible,
                  toggle: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
                    if (v != _passwordController.text)
                      return 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cyan,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "ចុះឈ្មោះ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "មានគណនីរួចហើយ?",
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "ចូល",
                        style: TextStyle(
                          color: AppColor.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
