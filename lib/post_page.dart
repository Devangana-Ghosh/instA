import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'profile_page.dart'; // Import ProfilePage

class PostPage extends StatefulWidget {
  final String postId;

  PostPage({required this.postId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<Map<String, dynamic>> _postData;
  int likes = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _postData = fetchPostData();
  }

  Future<Map<String, dynamic>> fetchPostData() async {
    final url = 'https://api.mocklets.com/p6903/getPostAPI?id=${widget.postId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          likes = data['likes'] ?? 0;
        });
        return data;
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _postData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final post = snapshot.data!;
          final String username = post['username'] ?? 'Unknown User';
          final String profilePic = post['profile_pic'] ?? '';
          final String imageUrl = post['image'] ?? '';
          final String caption = post['caption'] ?? '';
          final String postDate = post['post_date'] ?? '';

          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(), // ✅ Opens correct user's profile
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider(profilePic),
                    ),
                    SizedBox(width: 8),
                    Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'post_image_${widget.postId}',
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(caption, style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                            color: isLiked ? Colors.blue : Colors.black),
                        onPressed: toggleLike,
                      ),
                      Text('$likes likes'),
                      SizedBox(width: 16),
                      Icon(Icons.comment),
                      Text(postDate),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
