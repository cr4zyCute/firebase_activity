import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  String? _errorMessage;

  Future<void> _signIn() async {
    final user = await _authController.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      _showSnackBar('Signed in as: ${user.email}');
      _clearFields();
    } else {
      setState(() {
        _errorMessage = 'Failed to sign in. Please check your credentials.';
      });
    }
  }

  Future<void> _signUp() async {
    final user = await _authController.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      _showSnackBar('Registered: ${user.email}');
      _clearFields();
    } else {
      setState(() {
        _errorMessage = 'Failed to register. Email may already be in use.';
      });
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Auth & Firestore'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome! Please sign in or register below.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', Icons.email, false),
            SizedBox(height: 10),
            _buildTextField(_passwordController, 'Password', Icons.lock, true),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('Sign In', Icons.login, Colors.blue, _signIn),
                _buildButton(
                  'Sign Up',
                  Icons.person_add,
                  Colors.green,
                  _signUp,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Registered Users:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
      obscureText: isPassword,
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<UserModel>>(
      stream: _authController.getUsers(),
      builder: (context, snapshot) {
        // Add debug prints
        print('\n🔥 StreamBuilder update:');
        print('   - Connection state: ${snapshot.connectionState}');
        print('   - Has error: ${snapshot.hasError}');
        print('   - Has data: ${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('❌ Stream error details: ${snapshot.error}');
          return Center(child: Text('Error loading users'));
        }

        final users = snapshot.data ?? [];
        print('👥 Users count in UI: ${users.length}');

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            print(
              '   - Displaying user ${index + 1}: ${user.email} (${user.id})',
            );

            return Card(
              child: ListTile(
                title: Text(user.email),
                subtitle: Text(
                  'Date and Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
