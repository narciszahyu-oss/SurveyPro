import 'dart:io';
import 'package:flutter/material.dart';

class EditItemScreen extends StatefulWidget {
  final dynamic item;
  const EditItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController locationController;
  late TextEditingController roomController;
  List<String> photoPaths = [];

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController(text: widget.item.location ?? '');
    roomController = TextEditingController(text: widget.item.room ?? '');
    photoPaths = widget.item.photos ?? []; // if you store photos as List<String>
  }

  @override
  void dispose() {
    locationController.dispose();
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roomController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Room',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Photos',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: photoPaths.isNotEmpty
                    ? photoPaths.map((path) {
                        return Stack(
                          children: [
                            Image.file(
                              File(path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.yellow),
                                    onPressed: () {
                                      // will open photo editor later
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        photoPaths.remove(path);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList()
                    : [
                        const Text(
                          'No photos yet.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    // save logic will come later
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
