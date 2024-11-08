import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  final String baseUrl = 'http://192.168.137.1:8082';  // Your backend URL
  Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');  // Replace with your login API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Print the API response for debugging
      print("API Response: $responseBody");

      // Check if userId exists and is not null
      if (responseBody.containsKey('userId') && responseBody['userId'] != null) {
        int userId = responseBody['userId'];

        // Save the userId in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);  // Storing the userId

        return responseBody['role'];  // Return the user role (Doctor, Patient, Admin)
      } else {
        print('userId is null or missing from the response');
        return null;
      }
    } else {
      print('Failed to login: ${response.statusCode}');
      return null;
    }
  }

  // Function to sign up a user (Patient role by default)
  Future<bool> signUpUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/api/users');  // Sign-up API endpoint
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userData),  // Convert user data to JSON format
    );

    if (response.statusCode == 201) {
      return true;  // Sign-up successful
    } else {
      print('Failed to sign up: ${response.statusCode}');
      return false;  // Sign-up failed
    }
  }

  // Search doctors based on specialization
  Future<List<dynamic>?> searchDoctors(String specialization) async {
    final url = Uri.parse('$baseUrl/api/doctors/specialization?specialization=$specialization');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to search doctors: ${response.statusCode}');
      return null;
    }
  }
  // For booking appointment
  Future<bool> bookAppointment(Map<String, dynamic> appointmentData) async {
    final url = Uri.parse('$baseUrl/api/appointments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointmentData),
    );
    return response.statusCode == 200;
  }

  // Function to get patient profile by userId
  Future<Map<String, dynamic>> getPatientProfile(int userId) async {
    final url = Uri.parse('$baseUrl/api/patients/by_userId/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // Return the patient data as a map
      } else {
        throw Exception('Failed to load patient profile');
      }
    } catch (e) {
      print('Error fetching patient profile: $e');
      throw e;
    }
  }
  // Function to get appointments by patient userId
  Future<List<dynamic>> getAppointmentsByPatientId(int userId) async {
    final url = Uri.parse('$baseUrl/api/appointments/patient/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // Return the list of appointments
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      throw e;
    }
  }

//   API FOR DOCTOR SERVICES

  // Fetch doctor details by doctorId
  Future<Map<String, dynamic>?> getDoctorDetails(int doctorId) async {
    final url = Uri.parse('$baseUrl/api/doctors/$doctorId'); // Ensure this matches the backend endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load doctor details: ${response.statusCode}');
      return null;
    }
  }


  // Update doctor details by doctorId
  Future<bool> updateDoctorDetails(int doctorId, Map<String, dynamic> doctorData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/doctors/$doctorId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(doctorData),
    );

    if (response.statusCode == 200) {
      // Successful update
      return true;
    } else {
      // Failed update
      print('Failed to update doctor details: ${response.statusCode}');
      return false;
    }
  }
  // Fetch shifts for a specific doctor using their doctorId
  Future<List<dynamic>> getDoctorShifts(int doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/shifts/doctor_shifts/$doctorId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Parse the response and return the shifts as a list
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch doctor shifts: ${response.statusCode}');
      return [];
    }
  }

//   create patient

  // Get all patients
  Future<List<dynamic>> getAllPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/api/patients'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load patients');
    }
  }
  // Get all doctors
  Future<List<dynamic>> getAllDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/api/doctors'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load doctors');
    }
  }
  // Delete a patient by ID
  Future<void> deletePatient(int patientId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/patients/$patientId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete patient');
    }
  }
  // Delete a doctor by ID
  Future<void> deleteDoctor(int doctorId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/doctors/$doctorId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete doctor');
    }
  }
  // Get all appointments for a doctor by doctorId
  Future<List<dynamic>> getAppointmentsForDoctor(int doctorId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/appointments/doctor/$doctorId'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load appointments');
    }
  }
  // Update a patient by ID (PUT request)
  Future<void> updatePatient(int patientId, Map<String, dynamic> patientData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/patients/$patientId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(patientData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
  }

  // Update a doctor by ID (PUT request)
  Future<void> updateDoctor(int doctorId, Map<String, dynamic> doctorData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/doctors/$doctorId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(doctorData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update doctor');
    }
  }

  // Function to add an inventory item (POST request)
  Future<void> addInventoryItem(Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(itemData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add inventory item');
    }
  }

  Future<List<dynamic>> getAllInventoryItems() async {
    final response = await http.get(Uri.parse('$baseUrl/api/inventory'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load inventory items');
    }
  }


}