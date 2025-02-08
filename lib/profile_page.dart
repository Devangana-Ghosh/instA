import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage(); // ✅ No username needed

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = fetchProfileData();
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
    final url = 'https://api.mocklets.com/p6903/getProfileAPI'; // ✅ No username required
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")), // ✅ Generic title
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final List posts = data['gallery'] ?? [];
          final List highlights = data['highlights'] ?? [];
          final String profilePic = data['profile_pic'] ?? '';
          final String name = data['username'] ?? 'Unknown User';
          final int followers = data['followers'] ?? 0;
          final int following = data['following'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(profilePic),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('$followers Followers · $following Following'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Highlights Section
                if (highlights.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Highlights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: highlights.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider(highlights[index]['cover'] ?? ''),
                              ),
                              SizedBox(height: 4),
                              Text(highlights[index]['title'] ?? '', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Posts Grid
                if (posts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Posts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final String imageUrl = "${post['image']}?seed=$index"; // ✅ Unique image variation

                      return GestureDetector(
                        onTap: () {
                          if (post['id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostPage(postId: post['id'].toString()),
                              ),
                            );
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No posts available", style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
