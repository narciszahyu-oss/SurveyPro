import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'item_screen.dart';
import 'edit_item_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProjectScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  const ProjectScreen({super.key, required this.project});

  static const Color green = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF239B56);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  List<Map<String, dynamic>> _items = [];
  late Box _projectsBox;

  @override
  void initState() {
    super.initState();
    _projectsBox = Hive.box('projectsBox');
  }

  // ✅ Async loader to get items smoothly
  Future<List<Map<String, dynamic>>> _loadItems() async {
    await Future.delayed(const Duration(milliseconds: 100)); // short buffer
    final stored = _projectsBox.get(widget.project['projectName']);
    if (stored != null && stored['items'] != null) {
      return List<Map<String, dynamic>>.from(stored['items']);
    } else {
      return List<Map<String, dynamic>>.from(widget.project['items'] ?? []);
    }
  }

  // ✅ Save items to Hive
  Future<void> _saveToHive() async {
    final projectName = widget.project['projectName'];
    final stored = _projectsBox.get(projectName);

    final existingItems = stored != null && stored['items'] != null
        ? List<Map<String, dynamic>>.from(stored['items'])
        : <Map<String, dynamic>>[];

    for (final newItem in _items) {
      final alreadyExists = existingItems.any((oldItem) =>
          oldItem['location'] == newItem['location'] &&
          oldItem['room'] == newItem['room'] &&
          oldItem['description'] == newItem['description']);
      if (!alreadyExists) existingItems.add(newItem);
    }

    widget.project['items'] = existingItems;
    await _projectsBox.put(projectName, widget.project);

    setState(() {
      _items = List<Map<String, dynamic>>.from(existingItems);
    });
  }

  Future<void> _addNewItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemScreen(project: widget.project)),
    );

    if (newItem != null) {
      setState(() {
        _items.add(Map<String, dynamic>.from(newItem));
      });
      await _saveToHive();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: ProjectScreen.green,
        ),
      );
    }
  }

  Future<void> _editItem(int index) async {
    final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemScreen(item: _items[index]),
      ),
    );

    if (updatedItem != null) {
      setState(() {
        _items[index] = Map<String, dynamic>.from(updatedItem);
      });
      await _saveToHive();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated.'),
          backgroundColor: ProjectScreen.green,
        ),
      );
    }
  }

  Future<void> _deleteItem(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _items.removeAt(index);
      });
      await _saveToHive();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ProjectScreen.green,
        title: Text(widget.project['projectName'] ?? 'Project'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add Item',
            icon: SvgPicture.asset(
              'assets/icons/add_item.svg',
              width: 26,
              height: 26,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: _addNewItem,
          ),
        ],
      ),

      // ⚡️Instant load with FutureBuilder
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          _items = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Property Type: ${widget.project['propertyType']}'),
                Text('Client Type: ${widget.project['clientType']}'),
                Text('Inspector: ${widget.project['inspector']}'),
                Text('Inspection Type: ${widget.project['inspectionType']}'),
                Text(
                    'Date: ${widget.project['date'].toString().split("T").first}'),
                const SizedBox(height: 20),
                const Text(
                  'Project Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: GestureDetector(
                            onTap: _addNewItem,
                            child: Text(
                              'No items added yet.\nTap the ➕ icon to add one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final photoPath = (item['photos'] != null &&
                                    item['photos'].isNotEmpty)
                                ? item['photos'].first
                                : null;

                            return InkWell(
                              onTap: () => _editItem(index),
                              child: Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: photoPath != null
                                      ? (kIsWeb
                                          ? Image.network(
                                              photoPath,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(photoPath),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ))
                                      : const Icon(Icons.photo,
                                          size: 50, color: Colors.grey),
                                  title:
                                      Text(item['location'] ?? 'No location'),
                                  subtitle: Text(item['room'] ?? ''),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => _editItem(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteItem(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                if (_items.isNotEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: _addNewItem,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '➕ Tap to add another item',
                          style: TextStyle(
                            color: ProjectScreen.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        color: ProjectScreen.darkGreen,
        height: 45,
        alignment: Alignment.center,
        child: const Text(
          'SurveyPro Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
