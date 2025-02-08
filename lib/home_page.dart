import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feed_page.dart';
import 'profile_page.dart';
import 'theme_provider.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FeedPage(),
    Center(child: Text('Search Page')), // Replace with actual SearchPage widget
    Center(child: Text('Add Post Page')), // Replace with actual AddPostPage widget
    Center(child: Text('Reels Page')), // Replace with actual ReelsPage widget
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/instagram_logo.png', // Make sure the Instagram logo is added in assets
          height: 48,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // Handle Likes
            },
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Handle Direct Messages
            },
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: themeProvider.isDarkMode
                  ? Icon(Icons.dark_mode, key: ValueKey('dark'))
                  : Icon(Icons.light_mode, key: ValueKey('light')),
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Add Post'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Reels'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}