import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'folder_inside.dart';

class FolderViewPage extends StatelessWidget {
  const FolderViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: CustomTopNav(initialIndex: 1),
        body: FolderContent(),
        backgroundColor: Color(0xFF3A1078),
        bottomNavigationBar: CustomBottomNav(initialIndex: 2),
      ),
    );
  }
}

class FolderContent extends StatelessWidget {
  const FolderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FolderCard(
            folderName: 'Folder 1',
            itemCount: '10 Items',
            createdBy: 'User A',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FolderInside()),
              );
            },
          ),
          const SizedBox(height: 16),
          FolderCard(
            folderName: 'Folder 2',
            itemCount: '15 Items',
            createdBy: 'User B',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FolderInside()),
              );
            },
          ),
          const SizedBox(height: 16),
          FolderCard(
            folderName: 'Folder 3',
            itemCount: '20 Items',
            createdBy: 'User C',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FolderInside()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FolderCard extends StatelessWidget {
  final String folderName;
  final String itemCount;
  final String createdBy;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.folderName,
    required this.itemCount,
    required this.createdBy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, size: 40), // Folder icon
                const SizedBox(width: 10),
                Text(
                  folderName, // Folder name
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 20), // Item count icon
                const SizedBox(width: 5),
                Text(itemCount), // Item count text
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 20), // User icon
                const SizedBox(width: 5),
                Text(createdBy), // Created by text
              ],
            ),
          ],
        ),
      ),
    );
  }
}
