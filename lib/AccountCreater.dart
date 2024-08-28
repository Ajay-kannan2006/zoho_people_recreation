import 'package:flutter/material.dart';

// import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class EnrollmentPage extends StatefulWidget {
  @override
  _EnrollmentPageState createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAuthenticating = false;
  bool _isEnrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enroll Fingerprint")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _enrollFingerprint,
              child: Text(
                  _isEnrolled ? "Fingerprint Enrolled" : "Enroll Fingerprint"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enrollFingerprint() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter an email.")));
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enroll your fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        // Save the user's email and fingerprint data (hashed or securely stored) in Firestore
        await _firestore.collection('users').doc(email).set({
          'email': email,
          'fingerprint':
              'dummy_fingerprint_data', // Replace with actual fingerprint data if possible
          'enrolled': true,
        });

        setState(() {
          _isEnrolled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Fingerprint enrolled successfully.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Fingerprint enrollment failed.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      _isAuthenticating = false;
    });
  }
}
