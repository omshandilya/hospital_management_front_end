import 'package:flutter/material.dart';
import 'api_services.dart'; // Import your ApiService here

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiService apiService = ApiService(); // Initialize ApiService instance

  List<dynamic> patients = [];
  List<dynamic> doctors = [];
  bool isLoadingPatients = true;
  bool isLoadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _fetchAllPatients();
    _fetchAllDoctors();
  }

  // Fetch all patients using ApiService
  Future<void> _fetchAllPatients() async {
    try {
      final fetchedPatients = await apiService.getAllPatients();
      setState(() {
        patients = fetchedPatients;
        isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPatients = false;
      });
    }
  }

  // Fetch all doctors using ApiService
  Future<void> _fetchAllDoctors() async {
    try {
      final fetchedDoctors = await apiService.getAllDoctors();
      setState(() {
        doctors = fetchedDoctors;
        isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        isLoadingDoctors = false;
      });
    }
  }

  // Delete a patient using ApiService
  Future<void> _deletePatient(int patientId) async {
    try {
      await apiService.deletePatient(patientId);
      setState(() {
        patients.removeWhere((patient) => patient['patientId'] == patientId);
      });
    } catch (e) {
      // Handle error
    }
  }

  // Delete a doctor using ApiService
  Future<void> _deleteDoctor(int doctorId) async {
    try {
      await apiService.deleteDoctor(doctorId);
      setState(() {
        doctors.removeWhere((doctor) => doctor['doctorId'] == doctorId);
      });
    } catch (e) {
      // Handle error
    }
  }

  // Add new inventory item using ApiService
  Future<void> _addInventoryItem(Map<String, dynamic> itemData) async {
    try {
      await apiService.addInventoryItem(itemData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory item added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add inventory item')),
      );
    }
  }

  // Open dialog to add new inventory item
  void _showAddInventoryDialog() {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inventory Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField('Item Name', itemNameController),
                _buildEditableField('Category', categoryController),
                _buildEditableField('Quantity', quantityController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final Map<String, dynamic> itemData = {
                  'itemName': itemNameController.text,
                  'category': categoryController.text,
                  'quantityInStock': int.tryParse(quantityController.text) ?? 0,
                };
                _addInventoryItem(itemData);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Editable field widget
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // Build patient and doctor lists with edit and delete options
  Widget _buildListSection(String title, List<dynamic> items, bool isPatient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${items.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...items.map((item) {
          TextEditingController nameController =
          TextEditingController(text: item['name']);
          TextEditingController ageController =
          TextEditingController(text: item['age'].toString());
          TextEditingController specializationController =
          TextEditingController(
              text: isPatient ? '' : item['specialization']);
          return Card(
            child: ExpansionTile(
              title: Text(item['name']),
              subtitle: isPatient
                  ? Text(
                  'Age: ${item['age']}, Address: ${item['address']}, Phone: ${item['phoneNumber']}')
                  : Text('Specialization: ${item['specialization']}'),
              children: [
                _buildEditableField('Name', nameController),
                if (isPatient) _buildEditableField('Age', ageController),
                if (!isPatient)
                  _buildEditableField('Specialization', specializationController),
                ButtonBar(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        isPatient
                            ? _deletePatient(item['patientId'])
                            : _deleteDoctor(item['doctorId']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(
                          context,
                          isPatient,
                          isPatient ? item['patientId'] : item['doctorId'],
                          nameController.text,
                          isPatient
                              ? ageController.text
                              : specializationController.text,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Edit dialog for patients and doctors
  void _showEditDialog(BuildContext context, bool isPatient, int id,
      String name, String additionalField) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController additionalFieldController =
    TextEditingController(text: additionalField);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isPatient ? 'Edit Patient' : 'Edit Doctor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditableField('Name', nameController),
              if (isPatient) _buildEditableField('Age', additionalFieldController),
              if (!isPatient)
                _buildEditableField('Specialization', additionalFieldController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (isPatient) {
                  _updatePatient(id, {
                    'name': nameController.text,
                    'age': int.tryParse(additionalFieldController.text) ?? 0,
                  });
                } else {
                  _updateDoctor(id, {
                    'name': nameController.text,
                    'specialization': additionalFieldController.text,
                  });
                }
                Navigator.pop(context); // Close dialog after updating
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update a patient using ApiService
  Future<void> _updatePatient(int patientId, Map<String, dynamic> patientData) async {
    try {
      await apiService.updatePatient(patientId, patientData);
      _fetchAllPatients();
    } catch (e) {
      // Handle error
    }
  }

  // Update a doctor using ApiService
  Future<void> _updateDoctor(int doctorId, Map<String, dynamic> doctorData) async {
    try {
      await apiService.updateDoctor(doctorId, doctorData);
      _fetchAllDoctors();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddInventoryDialog, // Add inventory button
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoadingPatients
                ? const Center(child: CircularProgressIndicator())
                : _buildListSection('Patients', patients, true),
            isLoadingDoctors
                ? const Center(child: CircularProgressIndicator())
                : _buildListSection('Doctors', doctors, false),
          ],
        ),
      ),
    );
  }
}


