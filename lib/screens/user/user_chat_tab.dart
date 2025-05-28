import 'package:flutter/material.dart';

class UserChatTab extends StatefulWidget {
  const UserChatTab({super.key});

  @override
  State<UserChatTab> createState() => _UserChatTabState();
}

class _UserChatTabState extends State<UserChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _astrologers = [
    {
      'name': 'Dr. Anil Sharma',
      'specialty': 'Vedic Astrology',
      'rating': 4.9,
      'reviews': 245,
      'image': 'https://via.placeholder.com/150',
      'online': true,
    },
    {
      'name': 'Pandit Rajesh Kumar',
      'specialty': 'Palmistry & Numerology',
      'rating': 4.8,
      'reviews': 189,
      'image': 'https://via.placeholder.com/150',
      'online': true,
    },
    {
      'name': 'Acharya Vinod Kumar',
      'specialty': 'Vastu Consultant',
      'rating': 4.7,
      'reviews': 156,
      'image': 'https://via.placeholder.com/150',
      'online': false,
    },
    {
      'name': 'Dr. Neha Sharma',
      'specialty': 'Tarot Reading',
      'rating': 4.9,
      'reviews': 267,
      'image': 'https://via.placeholder.com/150',
      'online': true,
    },
    {
      'name': 'Swami Prakash',
      'specialty': 'Spiritual Guidance',
      'rating': 4.8,
      'reviews': 198,
      'image': 'https://via.placeholder.com/150',
      'online': false,
    },
  ];

  final List<Map<String, dynamic>> _recentChats = [
    {
      'name': 'Dr. Anil Sharma',
      'lastMessage': 'Your Saturn transit will end next month.',
      'time': '10:45 AM',
      'unread': 2,
      'image': 'https://via.placeholder.com/150',
      'online': true,
    },
    {
      'name': 'Dr. Neha Sharma',
      'lastMessage': 'The cards suggest patience at this time.',
      'time': 'Yesterday',
      'unread': 0,
      'image': 'https://via.placeholder.com/150',
      'online': true,
    },
    {
      'name': 'Acharya Vinod Kumar',
      'lastMessage': 'Try placing a plant in the northeast corner.',
      'time': '2 days ago',
      'unread': 0,
      'image': 'https://via.placeholder.com/150',
      'online': false,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade700,
                Colors.blue.shade700,
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.chat,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chat with Experts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get personalized guidance for your questions',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search astrologers, topics...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        
        // Tabs for Recent and Experts
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: [
                    Tab(text: 'RECENT CHATS'),
                    Tab(text: 'EXPERTS'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Recent Chats Tab
                      _buildRecentChatsTab(),
                      
                      // Experts Tab
                      _buildExpertsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentChatsTab() {
    return _recentChats.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No recent conversations',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start chatting with an expert now!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _recentChats.length,
            itemBuilder: (context, index) {
              final chat = _recentChats[index];
              return _buildChatItem(chat);
            },
          );
  }

  Widget _buildExpertsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _astrologers.length,
      itemBuilder: (context, index) {
        final expert = _astrologers[index];
        return _buildExpertItem(expert);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          if (chat['online'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat['name'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat['lastMessage'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat['unread'] > 0 ? Colors.black87 : Colors.grey.shade600,
          fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat['time'],
            style: TextStyle(
              fontSize: 12,
              color: chat['unread'] > 0 ? Colors.deepPurple : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (chat['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat['unread'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to chat detail
      },
    );
  }

  Widget _buildExpertItem(Map<String, dynamic> expert) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert image
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                if (expert['online'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Expert details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expert['specialty'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        expert['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${expert['reviews']} reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Book'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: BorderSide(color: Colors.deepPurple.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: expert['online'] ? () {} : null,
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 