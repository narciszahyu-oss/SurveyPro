import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/math_sheet_background.dart';

// Import new screens
import 'new_project_screen.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';
import 'share_screen.dart';
import 'help_screen.dart';
import 'project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF239B56);

  List<Map<String, dynamic>> _projects = [];
  late Box _projectsBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _projectsBox = Hive.box('projectsBox');
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final allProjects = _projectsBox.values.toList();
    setState(() {
      _projects = allProjects.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> _saveProject(Map<String, dynamic> project) async {
    await _projectsBox.put(project['projectName'], project);
    _loadProjects();
  }

  Future<void> _deleteProject(String projectName) async {
    await _projectsBox.delete(projectName);
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
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
                // 🏠 HOME
                InkWell(
                  onTap: _loadProjects,
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),

                // ➕ NEW PROJECT
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewProjectScreen(),
                      ),
                    );

                    if (result != null) {
                      await _saveProject(result);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectScreen(project: result),
                        ),
                      );
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/add.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),

                // ⚙️ SETTINGS
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/setting.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 LOGO SECTION
          SizedBox(
            width: double.infinity,
            height: 200,
            child: MathSheetBackground(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
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

          // 🔹 BODY GRID (Dynamic Project List)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _projects.isEmpty
                  ? Center(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewProjectScreen(),
                            ),
                          );
                          if (result != null) {
                            await _saveProject(result);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectScreen(project: result),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF2ECC71),
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap here to add your first project',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 48, color: green),
                            const SizedBox(height: 8),
                            Text(
                              project["projectName"] ?? "Untitled",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 📝 EDIT BUTTON
                               IconButton(
  icon: const Icon(Icons.edit, color: Color(0xFF2ECC71)),
  tooltip: 'Edit Project',
  onPressed: () async {
    // ✅ Preserve existing items (and photos)
    final existingProject = Map<String, dynamic>.from(project);
    existingProject['items'] = List<Map<String, dynamic>>.from(
      (project['items'] ?? []).cast<Map>(),
    );

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewProjectScreen(
          existingProject: existingProject,
        ),
      ),
    );

    if (updated != null) {
      // ✅ Merge back items and safely cast all types
      final mergedProject = Map<String, dynamic>.from(updated)
        ..['items'] = existingProject['items'];

      await _saveProject(mergedProject);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectScreen(project: mergedProject),
        ),
      );
    }
  },
),
                                // 🗑️ DELETE BUTTON
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  tooltip: 'Delete Project',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Delete Project"),
                                          content: Text(
                                            "Are you sure you want to delete '${project["projectName"]}'?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(color: Colors.redAccent),
                                              ),
                                              onPressed: () async {
                                                await _deleteProject(project["projectName"]);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Project deleted"),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/rate_review.svg',
                    width: 26,
                    height: 26,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShareScreen()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/share.svg',
                    width: 26,
                    height: 26,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpScreen()),
                    );
                  },
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
