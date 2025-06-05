import 'package:flutter/material.dart';

class UserCoursesScreen extends StatefulWidget {
  const UserCoursesScreen({super.key});

  @override
  State<UserCoursesScreen> createState() => _UserCoursesScreenState();
}

class _UserCoursesScreenState extends State<UserCoursesScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Featured', 'Astrology', 'Numerology', 'Tarot', 'Vastu'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryNavBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              
              // Course categories
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Category grid
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCategoryCard('Astrology Basics', Icons.stars, Colors.purple.shade700),
                  _buildCategoryCard('Tarot Reading', Icons.auto_stories, Colors.red.shade700),
                  _buildCategoryCard('Numerology', Icons.tag, Colors.green.shade700),
                  _buildCategoryCard('Meditation', Icons.self_improvement, Colors.orange.shade700),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Popular courses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getCoursesSectionTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Course cards
              _buildCourseCard(
                title: 'Introduction to Astrology',
                instructor: 'Prof. Jane Smith',
                duration: '8 hours',
                level: 'Beginner',
              ),
              const SizedBox(height: 16),
              _buildCourseCard(
                title: 'Advanced Tarot Reading',
                instructor: 'Dr. Michael Brown',
                duration: '12 hours',
                level: 'Intermediate',
              ),
              const SizedBox(height: 16),
              _buildCourseCard(
                title: 'Numerology Fundamentals',
                instructor: 'Sarah Johnson',
                duration: '6 hours',
                level: 'Beginner',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryNavBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedCategoryIndex == index 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: _selectedCategoryIndex == index 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade700,
                  fontWeight: _selectedCategoryIndex == index 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCoursesSectionTitle() {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'Popular Courses';
      case 1:
        return 'Astrology Courses';
      case 2:
        return 'Numerology Courses';
      case 3:
        return 'Tarot Courses';
      case 4:
        return 'Vastu Courses';
      default:
        return 'Popular Courses';
    }
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required String duration,
    required String level,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'By $instructor',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(duration),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: Colors.blue.shade800),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(level),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(color: Colors.green.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 