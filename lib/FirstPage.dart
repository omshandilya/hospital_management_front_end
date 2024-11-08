// import 'package:flutter/material.dart';
// import 'package:hospital_management/SignUpPage.dart';
//
// import 'LoginPage.dart';  // Import the login page
//
// class FirstPage extends StatefulWidget {
//   const FirstPage({super.key});
//
//   @override
//   State<FirstPage> createState() => _FirstPageState();
// }
//
// class _FirstPageState extends State<FirstPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade200,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,  // Centers the content
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Center(
//             child: Text(
//               "Hospital Management Application",
//               style: TextStyle(
//                 fontSize: 28,  // Increased text size
//                 fontWeight: FontWeight.bold,  // Make it bold like a heading
//                 color: Colors.white,  // White text for visibility on blue background
//               ),
//             ),
//           ),
//           SizedBox(height: 50),  // Adds space between the heading and the buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   // Navigate to the Login Page when clicked
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginPage()),  // Navigates to LoginPage
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.black, backgroundColor: Colors.white, // Button text color
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//                 child: Text("Login"),
//               ),
//               SizedBox(width: 20),  // Space between Login and Sign Up
//               ElevatedButton(
//                 onPressed: () {
//                   // For now, both buttons can navigate to the same login page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignUpPage()),  // Navigates to LoginPage
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white, backgroundColor: Colors.black,  // Button text color
//                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 ),
//                 child: Text("Sign Up"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:hospital_management/SignUpPage.dart';
import 'LoginPage.dart';  // Import the login page

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hospital Management System",
                style: TextStyle(
                  fontSize: 32,  // Increased text size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),  // Space between the heading and the buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.login, size: 30, color: Colors.blue.shade300),
                        title: Text(
                          "Login",
                          style: TextStyle(fontSize: 18, color: Colors.blue.shade300),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person_add, size: 30, color: Colors.blue.shade300),
                        title: Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



