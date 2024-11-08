import 'package:flutter/material.dart';
import 'api_services.dart'; // Import the correct service class

class DoctorPage extends StatefulWidget {
  final int doctorId; // Expecting a doctorId to fetch doctor details

  const DoctorPage({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final ApiService _apiServices = ApiService(); // Initialize ApiServices

  bool _isLoading = true;
  bool _isEditing = false;
  bool _available = false;
  List<dynamic> _shifts = []; // Store shifts for the doctor

  // Controllers to capture input from text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  // Function to fetch doctor shifts from the API
  Future<void> _fetchDoctorShifts() async {
    List<dynamic> shifts = await _apiServices.getDoctorShifts(widget.doctorId);
    setState(() {
      _shifts = shifts; // Set the shifts fetched from API
    });
  }

  // Function to fetch doctor details from the API
  Future<void> _fetchDoctorDetails() async {
    setState(() {
      _isLoading = true; // Show loading indicator while fetching
    });

    // Fetch doctor details using API
    Map<String, dynamic>? doctorData = await _apiServices.getDoctorDetails(widget.doctorId);

    if (doctorData != null) {
      // Populate the text controllers with data from the API
      _nameController.text = doctorData['name'];
      _specializationController.text = doctorData['specialization'];
      _available = doctorData['available'];
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Function to update doctor details using API
  Future<void> _saveDoctorDetails() async {
    Map<String, dynamic> doctorData = {
      'name': _nameController.text,
      'specialization': _specializationController.text,
      'available': _available
    };

    bool success = await _apiServices.updateDoctorDetails(widget.doctorId, doctorData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor details updated successfully!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update doctor details.'))
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails(); // Fetch doctor details when the page is loaded
    _fetchDoctorShifts();  // Fetch doctor shifts when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display doctor details form
            Form(
              key: GlobalKey<FormState>(), // Define your form key
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: true, // Allow editing
                  ),
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(labelText: 'Specialization'),
                    enabled: true, // Allow editing
                  ),
                  Row(
                    children: [
                      const Text('Available: '),
                      Switch(
                        value: _available,
                        onChanged: (value) {
                          setState(() {
                            _available = value;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _saveDoctorDetails,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display doctor shifts
            const Text(
              'Shifts:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _shifts.isNotEmpty
                ? Flexible(
              child: ListView.builder(
                itemCount: _shifts.length,
                itemBuilder: (context, index) {
                  final shift = _shifts[index];
                  return ListTile(
                    leading: Text('${index + 1}.'), // Add numbering to shifts
                    title: Text('Shift Day: ${shift['shiftDay']}'),
                    subtitle: Text('Shift Time: ${shift['shiftTime']}'),
                  );
                },
              ),
            )
                : const Text('No shifts available'),
          ],
        ),
      ),
    );
  }
}



