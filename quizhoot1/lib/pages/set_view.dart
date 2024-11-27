import 'package:flutter/material.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'set_inside.dart'; // Bu dosyayı ekleyin
import '../services/set_service.dart';

class FlashcardViewPage extends StatelessWidget {
  const FlashcardViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: CustomTopNav(initialIndex: 0),
        body: SetContent(),
        backgroundColor: Color(0xFF3A1078),
        bottomNavigationBar: CustomBottomNav(initialIndex: 2),
      ),
    );
  }
}

class SetContent extends StatefulWidget {
  const SetContent({super.key});

  @override
  _SetContentState createState() => _SetContentState();
}

class _SetContentState extends State<SetContent> {
  final SetService _setService = SetService();
  List<Map<String, dynamic>> sets = [];

  @override
  void initState() {
    super.initState();
    _fetchSets();
  }

  Future<void> _fetchSets() async {
    try {
      await _setService.fetchData();
      List<Map<String, dynamic>> fetchedSets = _setService.data;
      setState(() {
        sets = fetchedSets;
      });
    } catch (e) {
      print('Error fetching sets: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: sets.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You have not created any sets yet.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sets.map((set) {
          return Column(
            children: [
              SetCard(
                setName: set['set_name']!,
                termCount: set['size']!.toString(),
                createdBy: set['createdBy']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetInside.withSetID(setID: set['id']!),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class SetCard extends StatelessWidget {
  final String setName;
  final String termCount;
  final String createdBy;
  final VoidCallback onTap;

  const SetCard({
    super.key,
    required this.setName,
    required this.termCount,
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
                const Icon(Icons.format_list_numbered, size: 40), // Set ikonu
                const SizedBox(width: 10),
                Text(
                  setName, // Set adı buraya yazılacak
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20), // Terim sayısı ikonu
                const SizedBox(width: 5),
                Text(termCount), // Terim sayısı
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20), // Creator ikonu
                const SizedBox(width: 5),
                Text(createdBy), // Oluşturan kişi adı
              ],
            ),
          ],
        ),
      ),
    );
  }
}