import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_page.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<dynamic>> _feedData;

  @override
  void initState() {
    super.initState();
    _feedData = fetchFeedData();
  }

  Future<List<dynamic>> fetchFeedData() async {
    const url = 'https://api.mocklets.com/p6903/getFeedAPI';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('posts') && data['posts'] is List) {
          return data['posts'];
        } else {
          throw Exception('Unexpected response format: $data');
        }
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }

  void toggleLike(int index, List<dynamic> posts) {
    setState(() {
      posts[index]['liked'] = !(posts[index]['liked'] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feed")),
      body: FutureBuilder<List<dynamic>>(
        future: _feedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              final String username = post['username'] ?? 'Unknown User';
              final String profilePic = post['profile_pic'] ?? '';
              // ✅ Ensuring each post gets a unique image
              final String imageUrl = "${post['image']}?seed=$index";
              final String caption = post['caption'] ?? '';
              final String likesText = post['likes'] ?? '';
              final bool isLiked = post['liked'] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(postId: username),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(profilePic),
                        ),
                        title: Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.broken_image),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(caption, style: TextStyle(fontSize: 16)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                color: isLiked ? Colors.blue : Colors.grey),
                            onPressed: () => toggleLike(index, posts),
                          ),
                          Text(isLiked ? "1 like" : "0 likes"),
                          SizedBox(width: 16),
                          Icon(Icons.comment),
                          Text(likesText),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
