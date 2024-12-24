import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/User.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import '../classes/Set.dart';

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
  late User _user;
  bool _isLoading = true; // Add a loading state
  @override
  void initState() {
    _user = Provider.of<User>(context,listen:false);
    super.initState();
    _fetchSets(_user);
  }

  _deleteSet(int index){
    _user.components.elementAt(index).remove();
    _user.components.removeAt(index);
    setState(() {
      _user.components;
    });
  }

  Future<void> _fetchSets(User user) async {
    try {
      await user.fetchSets();
      setState(() {
        _isLoading = false; // Update loading state when data is fetched
      });
    } catch (e) {
      print('Error fetching sets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading your sets...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            )
          : _user.components.isEmpty
          ? const Column(
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
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _user.getSets().map((set) {

          return Column(
            children: [
              SetCard(
                set:set,
                creator: _user.username,
                onTap: () {

                  Navigator.pushNamed(
                    context,
                    '/setInside',
                    arguments: set,
                  );
                },
                onDelete: () => _deleteSet(_user.components.indexOf(set)), // Pass delete callback
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
  final Set set;
  final String creator;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SetCard({
    super.key,
    required this.set,
    required this.creator,
    required this.onTap,
    required this.onDelete,
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
                Expanded(
                  child: Text(
                    set.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: () async{
                    Navigator.pushNamed(
                        context,
                        '/flashcardUpdate',
                        arguments: set
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed: onDelete, // Call delete function
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20), // Terim sayısı ikonu
                const SizedBox(width: 5),
                Text(set.size.toString()), // Terim sayısı
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20), // Creator ikonu
                const SizedBox(width: 5),
                Text(creator), // Oluşturan kişi adı
              ],
            ),
          ],
        ),
      ),
    );
  }
}