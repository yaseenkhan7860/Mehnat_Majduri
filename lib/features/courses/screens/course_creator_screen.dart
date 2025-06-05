import 'package:flutter/material.dart';
import 'package:astro/flavors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CourseCreatorScreen extends StatefulWidget {
  const CourseCreatorScreen({super.key});

  @override
  State<CourseCreatorScreen> createState() => _CourseCreatorScreenState();
}

class _CourseCreatorScreenState extends State<CourseCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseTitleController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  final _coursePriceController = TextEditingController();
  String _selectedCategory = 'Programming';
  String _difficulty = 'Beginner';
  final List<String> _sections = ['Introduction'];

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _coursePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for user role instead of app flavor
    // We'll assume we need to implement this check differently
    // since the instructor flavor is now removed
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        actions: [
          TextButton.icon(
            onPressed: _saveCourse,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Course Information'),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _courseTitleController,
                  decoration: InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    hintText: 'Enter a compelling course title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _courseDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Course Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    hintText: 'Describe what students will learn',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(
                            value: 'Programming',
                            child: Text('Programming'),
                          ),
                          DropdownMenuItem(
                            value: 'Design',
                            child: Text('Design'),
                          ),
                          DropdownMenuItem(
                            value: 'Business',
                            child: Text('Business'),
                          ),
                          DropdownMenuItem(
                            value: 'Marketing',
                            child: Text('Marketing'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextFormField(
                        controller: _coursePriceController,
                        decoration: InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildDifficultySelection(),
                SizedBox(height: 24.h),
                _buildSectionTitle('Course Content'),
                SizedBox(height: 16.h),
                _buildSectionsList(),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: _addSection,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50.h),
                  ),
                  child: const Text('Save Course'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Difficulty Level:'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildDifficultyChip('Beginner'),
            _buildDifficultyChip('Intermediate'),
            _buildDifficultyChip('Advanced'),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(String label) {
    final isSelected = _difficulty == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _difficulty = label;
        });
      },
    );
  }

  Widget _buildSectionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(_sections[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _sections.removeAt(index);
                });
              },
            ),
            onTap: () {
              // Navigate to section editor
            },
          ),
        );
      },
    );
  }

  void _addSection() {
    setState(() {
      _sections.add('New Section ${_sections.length + 1}');
    });
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      // Save course data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 