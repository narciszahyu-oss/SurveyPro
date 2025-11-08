import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/math_sheet_background.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';
import 'share_screen.dart';
import 'help_screen.dart';

class NewProjectScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProject;

  const NewProjectScreen({super.key, this.existingProject});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  final TextEditingController _manualLocationController = TextEditingController();

  String _propertyType = 'Apartment';
  String _clientType = 'Business';
  String _inspectionType = 'Survey';
  DateTime _selectedDate = DateTime.now();

  static const Color green = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF239B56);

  @override
  void initState() {
    super.initState();

    // Prefill data if editing
    if (widget.existingProject != null) {
      final p = widget.existingProject!;
      _projectTitleController.text = p["projectName"] ?? "";
      _propertyType = p["propertyType"] ?? "Apartment";
      _clientType = p["clientType"] ?? "Business";
      _inspectorController.text = p["inspector"] ?? "";
      _inspectionType = p["inspectionType"] ?? "Survey";
      _manualLocationController.text = p["location"] ?? "";
      if (p["date"] != null) {
        _selectedDate = DateTime.tryParse(p["date"]) ?? DateTime.now();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _createOrUpdateProject() {
    if (_formKey.currentState!.validate()) {
      final bool isEditing = widget.existingProject != null;

      final Map<String, dynamic> projectData = {
        "id": isEditing
            ? widget.existingProject!["id"]
            : DateTime.now().millisecondsSinceEpoch.toString(),
        "title": "SurveyIN Pro",
        "projectName": _projectTitleController.text,
        "propertyType": _propertyType,
        "clientType": _clientType,
        "inspector": _inspectorController.text,
        "inspectionType": _inspectionType,
        "location": _manualLocationController.text,
        "date": _selectedDate.toIso8601String(),
        "createdAt": isEditing
            ? widget.existingProject!["createdAt"]
            : DateTime.now().toIso8601String(),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Project Updated Successfully!'
              : 'Project Created Successfully!'),
          backgroundColor: green,
        ),
      );

      Navigator.pop(context, projectData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingProject != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 TOP BAR
          Container(
            color: green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/setting.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 LOGO SECTION
          SizedBox(
            width: double.infinity,
            height: 180,
            child: MathSheetBackground(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png',
                        width: 80, height: 80, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    const Text(
                      'SurveyIN Pro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? "Edit Project Details" : "New Project Details",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Project Title
                    TextFormField(
                      controller: _projectTitleController,
                      decoration: const InputDecoration(
                        labelText: "Project Title",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Property Type
                    DropdownButtonFormField<String>(
                      value: _propertyType,
                      decoration: const InputDecoration(
                        labelText: "Property Type",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Apartment", child: Text("Apartment")),
                        DropdownMenuItem(value: "House", child: Text("House")),
                        DropdownMenuItem(
                            value: "Bungalow", child: Text("Bungalow")),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (val) => setState(() => _propertyType = val!),
                    ),
                    const SizedBox(height: 16),

                    // Client Type
                    DropdownButtonFormField<String>(
                      value: _clientType,
                      decoration: const InputDecoration(
                        labelText: "Client",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Business", child: Text("Business")),
                        DropdownMenuItem(
                            value: "Private", child: Text("Private")),
                      ],
                      onChanged: (val) => setState(() => _clientType = val!),
                    ),
                    const SizedBox(height: 16),

                    // Inspector
                    TextFormField(
                      controller: _inspectorController,
                      decoration: const InputDecoration(
                        labelText: "Inspector Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inspection Type
                    DropdownButtonFormField<String>(
                      value: _inspectionType,
                      decoration: const InputDecoration(
                        labelText: "Inspection Type",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Survey", child: Text("Survey")),
                        DropdownMenuItem(
                            value: "Snagging", child: Text("Snagging")),
                      ],
                      onChanged: (val) =>
                          setState(() => _inspectionType = val!),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Date",
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          "${_selectedDate.toLocal()}".split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Manual Location Input
                    TextFormField(
                      controller: _manualLocationController,
                      decoration: const InputDecoration(
                        labelText: "Manual Location",
                        hintText: "Start typing or enter your address",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _createOrUpdateProject,
                        child: Text(
                          isEditing ? "Save Changes" : "Create Project",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 BOTTOM BAR
          Container(
            color: darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackScreen()),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/rate_review.svg',
                    width: 26,
                    height: 26,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShareScreen()),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/share.svg',
                    width: 26,
                    height: 26,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpScreen()),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/help.svg',
                    width: 26,
                    height: 26,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
