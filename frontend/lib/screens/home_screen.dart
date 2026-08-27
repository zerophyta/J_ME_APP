import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int currentUserId;
  final String username;
  final String? avatarUrl;

  const HomeScreen({
    super.key,
    required this.currentUserId,
    required this.username,
    this.avatarUrl,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _startNewChat() {
    // TODO: open "start chat" flow (select user, create chat, navigate)
    debugPrint('Start new chat tapped');
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: plus button (left) and search bar (right)
            Row(
              children: [
                // Plus button on the left
                IconButton(
                  onPressed: _startNewChat,
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: 'Start chat',
                ),

                // Search bar to the right of the plus button
                Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (q) {
                        // TODO: filter contacts / chats
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second row: Title (bold J-me) and user avatar + username on the right
            Row(
              children: [
                // Title
                const Text(
                  'J-me',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                const Spacer(),

                // Username and avatar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
                      child: widget.avatarUrl == null
                          ? Text(widget.username.isNotEmpty
                              ? widget.username[0].toUpperCase()
                              : 'U')
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    // Placeholder list of chats; replace with real data
    final sample = List.generate(12, (i) => {
          "id": i + 1,
          "name": "Contact ${i + 1}",
          "lastMessage": "Last message preview ${i + 1}",
          "avatar": null,
        });

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sample.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = sample[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(item["name"][0]),
          ),
          title: Text(item["name"]),
          subtitle: Text(item["lastMessage"]),
          onTap: () {
            // TODO: navigate to ChatScreen with selected contact
            debugPrint('Open chat with ${item["name"]}');
          },
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildChatList();
      case 1:
        return const Center(child: Text('Groups (placeholder)'));
      case 2:
        return const Center(child: Text('Status (placeholder)'));
      case 3:
        return const Center(child: Text('Settings (placeholder)'));
      default:
        return _buildChatList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a transparent AppBar and put custom header in body to get full control
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // hide default toolbar area
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.circle_outlined), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
