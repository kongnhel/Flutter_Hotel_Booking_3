import 'dart:convert'; // For JSON encoding/decoding
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Core Flutter widgets
import 'package:hotel_booking/models/user_model.dart'; // User model definition
import 'package:hotel_booking/screens/root_app.dart'; // The main app shell with sidebar
import 'package:hotel_booking/theme/color.dart'; // Your app's custom color theme
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:hotel_booking/auth/register.dart'; // For navigating to the registration page
import 'package:shared_preferences/shared_preferences.dart'; // For local data storage (e.g., user session)

/// A stateful widget for the user login page.
/// This page allows users to enter their credentials and log in.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey for the Form widget to validate input fields.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers for email and password input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables for managing UI feedback during login.
  bool _isLoading = false; // To show a loading indicator on the button
  bool _isPasswordVisible = false; // To toggle password visibility

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed from the tree.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Login with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) throw Exception("User not found");

      // Get Firebase ID token
      String? idToken = await user.getIdToken();

      // Call your backend API to fetch user profile
      final response = await http.post(
        Uri.parse(
          "https://flutter-hotel-booking-api-2.onrender.com/api/users/login",
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final userModel = UserModel.fromJson(responseBody);

        final prefs = await SharedPreferences.getInstance();

        // Save user model JSON and user email separately for session persistence
        await prefs.setString('user', json.encode(userModel.toJson()));
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('userId', user.uid ?? '');
        await prefs.setString(
          'userRole',
          userModel.role,
        ); // Save the user's role

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ចូលដោយជោគជ័យ! សូមស្វាគមន៍ត្រឡប់មកវិញ, ${user.email}',
              ), // Login successful! Welcome back,
              backgroundColor: Colors.green,
            ),
          );
        }

        if (mounted) {
          // ALWAYS navigate to RootApp after successful login.
          // RootApp will then decide which initial screen (HomePage or AdminDashboardPage) to show
          // based on the user's role, and it will provide the sidebar.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RootApp()),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['error'] ?? 'ការចូលបរាជ័យ'; // Login failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message =
          'ការចូលបរាជ័យ។ សូមពិនិត្យមើលព័ត៌មានសម្ងាត់របស់អ្នក។'; // Login failed. Please check your credentials.
      if (e.code == 'user-not-found')
        message =
            'រកមិនឃើញអ្នកប្រើប្រាស់សម្រាប់អ៊ីមែលនោះទេ។'; // No user found for that email.
      if (e.code == 'wrong-password')
        message =
            'ពាក្យសម្ងាត់ខុសត្រូវបានផ្តល់ជូន។'; // Wrong password provided.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } on http.ClientException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "កំហុសបណ្តាញ: មិនអាចភ្ជាប់ទៅម៉ាស៊ីនមេបានទេ។ សូមពិនិត្យមើលការតភ្ជាប់អ៊ីនធឺណិតរបស់អ្នក។", // Network error: Could not connect to the server. Please check your internet connection.
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("កំហុសដែលមិនបានរំពឹងទុក: $e"), // Unexpected error:
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColor.appBgColor, // Set background color from your theme
      appBar: AppBar(
        title: const Text(
          "ចូល", // Login
          style: TextStyle(color: AppColor.textColor), // AppBar title style
        ),
        backgroundColor: AppColor.appBarColor, // AppBar background color
        elevation: 0, // Remove shadow for a flat look
      ),
      // The main content of the login page, centered and scrollable.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey, // Assign the form key for validation
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children horizontally
              children: [
                // Welcome Back! text
                Text(
                  "សូមស្វាគមន៍ត្រឡប់មកវិញ!", // Welcome Back!
                  style: TextStyle(
                    color: AppColor.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Sign in message
                Text(
                  "ចូលដើម្បីបន្តទៅគណនីរបស់អ្នក", // Sign in to continue to your account
                  style: TextStyle(color: AppColor.labelColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Email Input Field
                _buildTextFormField(
                  controller: _emailController,
                  labelText: "អ៊ីមែល", // Email
                  hintText: "បញ្ចូលអ៊ីមែលរបស់អ្នក", // Enter your email
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'សូមបញ្ចូលអ៊ីមែលរបស់អ្នក'; // Please enter your email
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលត្រឹមត្រូវ'; // Please enter a valid email address
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Input Field
                _buildPasswordFormField(
                  controller: _passwordController,
                  labelText: "ពាក្យសម្ងាត់", // Password
                  hintText: "បញ្ចូលពាក្យសម្ងាត់របស់អ្នក", // Enter your password
                  isVisible: _isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'សូមបញ្ចូលពាក្យសម្ងាត់របស់អ្នក'; // Please enter your password
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'មុខងារភ្លេចពាក្យសម្ងាត់នឹងមកដល់ឆាប់ៗនេះ!', // Forgot Password functionality coming soon!
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "ភ្លេចពាក្យសម្ងាត់?", // Forgot Password?
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button while loading
                      : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cyan, // Button background color
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
                      : Text(
                          "ចូល", // Login
                          style: TextStyle(
                            color:
                                AppColor.textColor, // Text color for the button
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Register Redirect Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "មិនមានគណនីទេ?", // Don't have an account?
                      style: TextStyle(
                        color: AppColor.labelColor,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "ចុះឈ្មោះ", // Register
                        style: TextStyle(
                          color: AppColor
                              .cyan, // Primary color for the register link
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Removed the "Continue to Page" button as it bypasses login and is redundant
                    // with the main app's login check.
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to build a standard text form field with consistent styling.
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColor.labelColor),
        filled: true,
        fillColor: AppColor.appBarColor, // Background color for the input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // No border line
        ),
        labelStyle: TextStyle(color: AppColor.labelColor),
        hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
      ),
      style: TextStyle(color: AppColor.textColor), // Text input color
      validator: validator, // Validator function for input validation
    );
  }

  /// Helper widget to build a password text form field with a toggle visibility icon.
  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible, // Hide text if not visible
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.labelColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off
                : Icons.visibility, // Toggle icon based on visibility
            color: AppColor.labelColor,
          ),
          onPressed: toggleVisibility, // Callback to change visibility state
        ),
        filled: true,
        fillColor: AppColor.appBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: AppColor.labelColor),
        hintStyle: TextStyle(color: AppColor.labelColor.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
      ),
      style: TextStyle(color: AppColor.textColor),
      validator: validator,
    );
  }
}
