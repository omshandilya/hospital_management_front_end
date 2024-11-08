// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'api_services.dart';
// class PatientPage extends StatefulWidget {
//   final int userId;
//
//   const PatientPage({super.key, required this.userId});
//
//   @override
//   _PatientPageState createState() => _PatientPageState();
// }
// class _PatientPageState extends State<PatientPage> {
//   final ApiService apiService = ApiService();
//   Map<String, dynamic>? patientProfile;
//   List<dynamic>? appointments;
//   TextEditingController searchController = TextEditingController();
//   List<dynamic>? searchedDoctors;
//   @override
//   void initState() {
//     super.initState();
//     _loadPatientData();
//   }
//
//   Future<void> _loadPatientData() async {
//     try {
//       var profile = await apiService.getPatientProfile(widget.userId);
//       var appts = await apiService.getAppointmentsByPatientId(widget.userId);
//
//       setState(() {
//         patientProfile = profile;
//         appointments = appts;
//       });
//     } catch (e) {
//       print('Failed to load patient data: $e');
//     }
//   }
//
//   Future<void> _searchDoctors(String specialization) async {
//     try {
//       var doctors = await apiService.searchDoctors(specialization);
//       setState(() {
//         searchedDoctors = doctors;
//       });
//     } catch (e) {
//       print('Failed to search doctors: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Patient Dashboard'),
//       ),
//       body: patientProfile == null || appointments == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Patient Profile Section
//             const Text(
//               "Patient Profile",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text("Name: ${patientProfile!['name']}"),
//             Text("Age: ${patientProfile!['age']}"),
//             Text("Address: ${patientProfile!['address']}"),
//             const SizedBox(height: 20),
//
//             // Appointments Section
//             const Text(
//               "Appointments",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             appointments!.isEmpty
//                 ? const Text("No appointments available.")
//                 : ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: appointments!.length,
//               itemBuilder: (context, index) {
//                 var appointment = appointments![index];
//                 return ListTile(
//                   title: Text("Reason: ${appointment['reason']}"),
//                   subtitle: Text("Date: ${appointment['appointmentDate']}"),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//
//             // Search Doctors Section
//             const Text(
//               "Search Doctors by Specialization",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: searchController,
//               decoration: const InputDecoration(
//                 labelText: "Enter specialization",
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: (value) => _searchDoctors(value),
//             ),
//             const SizedBox(height: 10),
//             searchedDoctors == null
//                 ? Container()
//                 : searchedDoctors!.isEmpty
//                 ? const Text("No doctors found.")
//                 : ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: searchedDoctors!.length,
//               itemBuilder: (context, index) {
//                 var doctor = searchedDoctors![index];
//                 return ListTile(
//                   title: Text("Doctor: ${doctor['name']}"),
//                   subtitle:
//                   Text("Specialization: ${doctor['specialization']}"),
//                   trailing: doctor['available'] == true
//                       ? const Text("Available",
//                       style: TextStyle(color: Colors.green))
//                       : const Text("Not Available",
//                       style: TextStyle(color: Colors.red)),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//
//             // Button to Book Appointment
//             ElevatedButton(
//               onPressed: () {
//                 _bookAppointment();
//               },
//               child: const Text("Book Appointment"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _bookAppointment() async {
//     // Example appointment data
//     Map<String, dynamic> appointmentData = {
//       'userId': widget.userId,
//       'reason': 'Regular Checkup',
//       'appointmentDate': '2023-12-01T10:00:00',
//     };
//
//     bool success = await apiService.bookAppointment(appointmentData);
//     if (success) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Appointment booked successfully!")));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Failed to book appointment")));
//     }
//   }
// }
//



// PatientPage.dart
import 'package:flutter/material.dart';
import 'api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? patientProfile;
  List<dynamic>? appointments;
  List<dynamic>? searchedDoctors;

  TextEditingController specializationController = TextEditingController();
  TextEditingController doctorIdController = TextEditingController();
  TextEditingController appointmentDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load userId from SharedPreferences
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    if (userId != null) {
      _loadPatientData(); // Load patient data if userId is available
      _loadAppointments(); // Load appointment history
    } else {
      print("UserId not found in SharedPreferences");
    }
  }

  Future<void> _loadPatientData() async {
    try {
      var profile = await apiService.getPatientProfile(userId!);
      setState(() {
        patientProfile = profile;
      });
    } catch (e) {
      print('Failed to load patient data: $e');
    }
  }

  Future<void> _loadAppointments() async {
    try {
      var appts = await apiService.getAppointmentsByPatientId(userId!);
      setState(() {
        appointments = appts;
      });
    } catch (e) {
      print('Failed to load appointments: $e');
    }
  }

  Future<void> _searchDoctors() async {
    String specialization = specializationController.text;
    if (specialization.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a specialization')),
      );
      return;
    }

    try {
      var doctors = await apiService.searchDoctors(specialization);
      setState(() {
        searchedDoctors = doctors;
      });
    } catch (e) {
      print('Failed to search doctors: $e');
    }
  }

  Future<void> _bookAppointment() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UserId not available')),
      );
      return;
    }

    String doctorId = doctorIdController.text;
    String appointmentDate = appointmentDateController.text;
    String reason = reasonController.text;

    if (doctorId.isEmpty || appointmentDate.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    Map<String, dynamic> appointmentData = {
      'patientId': patientProfile!['patientId']!,
      'doctorId': int.parse(doctorId), // Convert to int
      'appointmentDate': appointmentDate,
      'reason': reason,
    };

    bool success = await apiService.bookAppointment(appointmentData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book appointment")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC), // Softer blue background
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: const Color(0xFF0288D1), // Darker blue
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Patient Profile"),
            const SizedBox(height: 10),
            _buildPatientProfile(),
            const SizedBox(height: 20),

            _buildSectionTitle("Appointments History"),
            const SizedBox(height: 10),
            _buildAppointmentsList(),
            const SizedBox(height: 20),

            _buildSectionTitle("Search Doctors by Specialization"),
            const SizedBox(height: 10),
            _buildSearchDoctorsSection(),
            const SizedBox(height: 20),

            _buildSectionTitle("Book Appointment"),
            const SizedBox(height: 10),
            _buildBookAppointmentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0288D1),
      ),
    );
  }

  Widget _buildPatientProfile() {
    return patientProfile == null
        ? const Center(child: CircularProgressIndicator())
        : Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${patientProfile!['name']}"),
          Text("Age: ${patientProfile!['age']}"),
          Text("Address: ${patientProfile!['address']}"),
          Text("Patient Id: ${patientProfile!['patientId']}")
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return appointments == null
        ? const Center(child: CircularProgressIndicator())
        : appointments!.isEmpty
        ? const Text("No appointments available.")
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments!.length,
      itemBuilder: (context, index) {
        var appointment = appointments![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10.0),
          child: ListTile(
            title: Text("Reason: ${appointment['reason']}"),
            subtitle: Text("Date: ${appointment['appointmentDate']}"),
          ),
        );
      },
    );
  }

  Widget _buildSearchDoctorsSection() {
    return Column(
      children: [
        TextField(
          controller: specializationController,
          decoration: const InputDecoration(
            labelText: "Enter specialization",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => _searchDoctors(),
        ),
        const SizedBox(height: 10),
        searchedDoctors == null
            ? Container()
            : searchedDoctors!.isEmpty
            ? const Text("No doctors found.")
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchedDoctors!.length,
          itemBuilder: (context, index) {
            var doctor = searchedDoctors![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                title: Text("Doctor: ${doctor['name']}"),
                subtitle: Text("Specialization: ${doctor['specialization']}"),
                trailing: doctor['available'] == true
                    ? const Text(
                  "Available",
                  style: TextStyle(color: Colors.green),
                )
                    : const Text(
                  "Not Available",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookAppointmentSection() {
    return Column(
      children: [
        TextField(
          controller: doctorIdController,
          decoration: const InputDecoration(
            labelText: "Enter Doctor ID",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: appointmentDateController,
          decoration: const InputDecoration(
            labelText: "Enter Appointment Date",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: "Enter Reason",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: const Color(0xFF0277BD), // Ensures text is visible
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: _bookAppointment,
          child: const Text("Book Appointment"),
        ),
      ],
    );
  }
}

