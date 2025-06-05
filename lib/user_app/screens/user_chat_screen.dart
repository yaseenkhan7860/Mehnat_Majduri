import 'package:flutter/material.dart';

class UserChatScreen extends StatelessWidget {
  const UserChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discussion Room Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade50,
                    Colors.green.shade100,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: Colors.green.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Discussion Room',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Join our live discussion room to connect with astrologers and other users. Get your questions answered in real-time!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '12',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Online now'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Open discussion room
                        },
                        icon: const Icon(Icons.forum),
                        label: const Text('Join Room'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Filter chips for astrologer types
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Love & Relationship', false),
                _buildFilterChip('Career', false),
                _buildFilterChip('Health', false),
                _buildFilterChip('Finance', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Astrologer listings
          _buildAstrologerCard(
            name: 'Guru Parmanand',
            specialty: 'Prashana Psychologist, Vedic',
            languages: 'English, Gujarati, Hindi, Spanish',
            experience: '10 Years',
            fee: '₹39/min',
            isFree: true,
            type: 'Prashana',
            isVerified: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildAstrologerCard(
            name: 'Sriram',
            specialty: 'Prashana Psychologist, Vedic',
            languages: 'English, Hindi',
            experience: '10 Years',
            fee: '₹39/min',
            isFree: true,
            type: 'Prashana',
            isVerified: false,
          ),
          
          const SizedBox(height: 12),
          
          _buildAstrologerCard(
            name: 'Vansh',
            specialty: 'Psychologist',
            languages: 'English, Hindi',
            experience: '12 Years',
            fee: '₹49/min',
            isFree: true,
            type: 'Psychologist',
            isVerified: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildAstrologerCard(
            name: 'Astro',
            specialty: 'Vedic',
            languages: 'Sanskrit',
            experience: '15 Years',
            fee: '₹45/min',
            isFree: true,
            type: 'Vedic',
            isVerified: true,
          ),
          
          const SizedBox(height: 12),
          
          _buildAstrologerCard(
            name: 'Aakarths Rajawat',
            specialty: 'Vastu',
            languages: 'Hindi, English',
            experience: '8 Years',
            fee: '₹35/min',
            isFree: true,
            type: 'Vastu',
            isVerified: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle filter selection
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green.shade700 : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.shade200),
        ),
      ),
    );
  }
  
  Widget _buildAstrologerCard({
    required String name,
    required String specialty,
    required String languages,
    required String experience,
    required String fee,
    required bool isFree,
    required String type,
    required bool isVerified,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Astrologer image with type label
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Astrologer details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and verification
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isVerified) 
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(Icons.verified, color: Colors.blue, size: 16),
                        ),
                    ],
                  ),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    languages,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Experience: $experience',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFree ? 'FREE' : fee,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      if (!isFree) 
                        Text(
                          ' $fee',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Call button
            ElevatedButton(
              onPressed: () {
                // Call astrologer
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Call'),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'prashana':
        return Colors.blue;
      case 'vedic':
        return Colors.green;
      case 'psychologist':
        return Colors.orange;
      case 'vastu':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 