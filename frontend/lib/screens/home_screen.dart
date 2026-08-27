import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final String username;
  final String? avatarUrl;
  final VoidCallback onStartChat;
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;

  const HeaderWidget({
    super.key,
    this.title = 'J-me',
    required this.username,
    this.avatarUrl,
    required this.onStartChat,
    required this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: plus button and search bar
            Row(
              children: [
                IconButton(
                  onPressed: onStartChat,
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: 'Start chat',
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second row: title and user info
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                      child: avatarUrl == null
                          ? Text(
                              username.isNotEmpty ? username[0].toUpperCase() : 'U',
                            )
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
}
