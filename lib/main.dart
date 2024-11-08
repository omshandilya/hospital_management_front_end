import 'package:flutter/material.dart';
import 'package:hospital_management/LoginPage.dart';
import 'AdminPage.dart';
import 'DoctorPage.dart';
import 'FirstPage.dart';
import 'PatientPage.dart';
import 'SignUpPage.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FirstPage(),
      routes: {
        '/admin': (context) => const AdminPage(),
        '/doctor': (context) => FutureBuilder<int?>(
          future: _getDoctorId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              // Pass the doctorId to DoctorPage
              return DoctorPage(doctorId: snapshot.data!);
            } else {
              return const LoginPage();
            }
          },
        ),
        '/patient': (context) => FutureBuilder<int?>(
          future: _getUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              return const PatientPage();
            } else {
              return const LoginPage();
            }
          },
        ),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }

  // Function to retrieve doctorId from SharedPreferences
  Future<int?> _getDoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('doctorId');
  }

  // Function to retrieve userId from SharedPreferences
  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}




