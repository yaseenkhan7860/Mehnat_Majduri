import 'package:flutter/material.dart';

class UserCoursesTab extends StatefulWidget {
  const UserCoursesTab({super.key});

  @override
  State<UserCoursesTab> createState() => _UserCoursesTabState();
}

class _UserCoursesTabState extends State<UserCoursesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Featured', 'Astrology', 'Vastu', 'Numerology', 'Tarot'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: _categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFeaturedTab(),
              _buildAstrologyTab(),
              _buildVastuTab(),
              _buildNumerologyTab(),
              _buildTarotTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.star,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Featured Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our most popular and recommended courses',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Featured courses list
          const Text(
            'Top Rated Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Course cards
          _buildCourseCard(
            title: 'Introduction to Astrology',
            instructor: 'Prof. Jane Smith',
            rating: 4.9,
            students: 1245,
            price: 'Rs. 1,999',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Advanced Tarot Reading',
            instructor: 'Dr. Michael Brown',
            rating: 4.8,
            students: 987,
            price: 'Rs. 2,499',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Vastu Shastra Fundamentals',
            instructor: 'Acharya Rajesh Kumar',
            rating: 4.7,
            students: 756,
            price: 'Rs. 1,799',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade700,
                  Colors.deepPurple.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_graph,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Astrology Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn the ancient science of celestial influence',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Astrology courses
          const Text(
            'Popular Astrology Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCourseCard(
            title: 'Vedic Astrology Fundamentals',
            instructor: 'Dr. Sharma',
            rating: 4.9,
            students: 2145,
            price: 'Rs. 2,299',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Planetary Influences & Remedies',
            instructor: 'Pandit Ravi Shankar',
            rating: 4.7,
            students: 1876,
            price: 'Rs. 1,899',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildVastuTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade700,
                  Colors.teal.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vastu Shastra',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ancient architectural wisdom for modern living',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Vastu courses
          const Text(
            'Vastu Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCourseCard(
            title: 'Vastu for Home Design',
            instructor: 'Acharya Vinod Kumar',
            rating: 4.8,
            students: 1432,
            price: 'Rs. 1,799',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Commercial Vastu Principles',
            instructor: 'Dr. Neha Sharma',
            rating: 4.6,
            students: 967,
            price: 'Rs. 2,499',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildNumerologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade700,
                  Colors.orange.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tag,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Numerology',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover the mystical significance of numbers',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Numerology courses
          const Text(
            'Numerology Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCourseCard(
            title: 'Pythagorean Numerology',
            instructor: 'Prof. Rajiv Malhotra',
            rating: 4.7,
            students: 1123,
            price: 'Rs. 1,599',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Name & Birth Number Analysis',
            instructor: 'Swami Prakash',
            rating: 4.9,
            students: 1567,
            price: 'Rs. 1,899',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildTarotTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade700,
                  Colors.pink.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tarot Reading',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master the art of tarot card interpretation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tarot courses
          const Text(
            'Tarot Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCourseCard(
            title: 'Tarot for Beginners',
            instructor: 'Madame Eliza',
            rating: 4.8,
            students: 2345,
            price: 'Rs. 1,499',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            title: 'Advanced Tarot Spreads',
            instructor: 'Master Ravindra',
            rating: 4.9,
            students: 1876,
            price: 'Rs. 2,299',
            imageUrl: 'https://via.placeholder.com/300x200',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required double rating,
    required int students,
    required String price,
    required String imageUrl,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          
          // Course details
          Padding(
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$students students',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Enroll'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 