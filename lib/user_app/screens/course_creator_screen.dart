import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Course Information'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter a compelling course title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Course Description',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _coursePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                _buildDifficultySelection(),
                const SizedBox(height: 24),
                _buildSectionTitle('Course Content'),
                const SizedBox(height: 16),
                _buildSectionsList(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addSection,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Section'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Difficulty Level:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
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
          margin: const EdgeInsets.only(bottom: 8.0),
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
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Section'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Section Title',
              hintText: 'e.g., Getting Started',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    _sections.add(textController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      // Save course logic would go here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // In a real app, we would save to Firestore and navigate back
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }
} 