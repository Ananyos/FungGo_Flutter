import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/mock_database.dart';
import '../widgets/song_card.dart';
import '../screens/sidebar_pages.dart'; // Import the new sidebar pages

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<LandingPage> {
  // Create a GlobalKey to control the Scaffold (to open drawer without an AppBar)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await MockDatabase.searchSongs(_searchController.text);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key here
      backgroundColor: Colors.white,
      
      // SIDEBAR (Drawer) - Kept the same functionality
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrange),
              accountName: Text("Music Lover"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.deepOrange),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Search History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookmarksPage()),
                );
              },
            ),
          ],
        ),
      ),

      // BODY - Restored to Original Design
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Header Row (Menu Button)
            // This replaces the AppBar but keeps it minimal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                    onPressed: () {
                      // Open the drawer using the GlobalKey
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),
            ),

            // 2. Original Logo/Text and Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                      'assets/images/logo_horizon.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                  
                  // ORIGINAL Search Box Design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search song, artist...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        // Original Button Design inside text field
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                          onPressed: _performSearch,
                        ),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Results List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                  : _hasSearched
                      ? _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              children: [
                                const Text(
                                  'Your results :',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ..._searchResults.map(
                                  (song) => SongCard(
                                    song: song,
                                    searchQuery: _searchController.text,
                                  ),
                                ),
                              ],
                            )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}