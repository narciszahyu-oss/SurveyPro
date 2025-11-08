import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class ItemScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ItemScreen({super.key, required this.project});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  static const Color green = Color(0xFF2ECC71);
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _assignedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedLocation;
  String _selectedRoom = "Living Room";
  final List<File> _photos = [];

  final List<String> _roomOptions = [
    "Living Room",
    "Dining Room",
    "Bedroom 1",
    "Bedroom 2",
    "Bedroom 3",
    "Bedroom 4",
    "Bedroom 5",
    "Bedroom 6",
    "Kitchen",
    "Bathroom",
    "Hallway",
    "Add Room"
  ];

  // 📸 Pick photo from gallery
  Future<void> _pickPhoto() async {
    if (_photos.length >= 4) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  // 📷 Take photo (Web-safe + Native)
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    if (kIsWeb) {
      // Web: no retry screen; just display directly
      setState(() {
        _photos.add(File(photo.path));
      });
    } else {
      // Mobile: Retry/Done flow
      if (_photos.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 4 photos allowed per item.')),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(
            imagePath: photo.path,
            onRetry: () async {
              try {
                await File(photo.path).delete();
              } catch (_) {}
              Navigator.pop(context);
              _takePhoto();
            },
            onDone: () async {
              final dir = await getApplicationDocumentsDirectory();
              final fileName =
                  'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final savedPath = path.join(dir.path, fileName);
              await File(photo.path).copy(savedPath);

              setState(() {
                _photos.add(File(savedPath));
              });
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final itemData = {
        "location": _selectedLocation ?? _floorController.text,
        "room": _selectedRoom,
        "assigned": _assignedController.text,
        "description": _descriptionController.text,
        "photos": _photos.map((f) => f.path).toList(),
      };
      Navigator.pop(context, itemData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyType = widget.project["propertyType"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        title: const Text("Add Item"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 LOCATION
              const Text(
                "Location",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (propertyType == "House" || propertyType == "Bungalow")
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Floor",
                  ),
                  items: const [
                    DropdownMenuItem(value: "Groundfloor", child: Text("Groundfloor")),
                    DropdownMenuItem(value: "1st Floor", child: Text("1st Floor")),
                    DropdownMenuItem(value: "2nd Floor", child: Text("2nd Floor")),
                    DropdownMenuItem(value: "3rd Floor", child: Text("3rd Floor")),
                    DropdownMenuItem(value: "4th Floor", child: Text("4th Floor")),
                    DropdownMenuItem(value: "Basement", child: Text("Basement")),
                  ],
                  onChanged: (val) => setState(() => _selectedLocation = val),
                )
              else
                TextFormField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    hintText: propertyType == "Apartment"
                        ? "Enter floor number (e.g. 8th floor)"
                        : "Enter location (e.g. Stadium)",
                    border: const OutlineInputBorder(),
                  ),
                ),

              const SizedBox(height: 16),

              // 🔹 ROOM TYPE
              const Text(
                "Room Type",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedRoom,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _roomOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) async {
                  if (val == "Add Room") {
                    final newRoom = await _showAddRoomDialog();
                    if (newRoom != null && newRoom.isNotEmpty) {
                      setState(() {
                        _roomOptions.insert(_roomOptions.length - 1, newRoom);
                        _selectedRoom = newRoom;
                      });
                    }
                  } else {
                    setState(() {
                      _selectedRoom = val!;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // 🔹 ASSIGNED TO
              const Text(
                "Assigned To",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _assignedController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter name",
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 DESCRIPTION
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g. Damage to ceiling",
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // 🔹 PHOTO SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickPhoto,
                    child: const Text("Add from Gallery"),
                  ),
                  ElevatedButton(
                    onPressed: _takePhoto,
                    child: const Text("Take Photo"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _photos.map((photo) {
                  // Web-safe image preview
                  return kIsWeb
                      ? Image.network(photo.path,
                          width: 100, height: 100, fit: BoxFit.cover)
                      : Image.file(photo,
                          width: 100, height: 100, fit: BoxFit.cover);
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 🔹 SAVE BUTTON
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
                  onPressed: _saveItem,
                  child: const Text(
                    "Save Item",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddRoomDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Custom Room"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter room name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text.trim()),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const PhotoPreviewScreen({
    Key? key,
    required this.imagePath,
    required this.onRetry,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  onPressed: onRetry,
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  onPressed: onDone,
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
