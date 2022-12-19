import 'package:bloc_app_example/features/posts/domain/entities/post.dart';
import 'package:bloc_app_example/features/posts/presentation/widgets/posts/post_tile.dart';
import 'package:flutter/cupertino.dart';

class PostsList extends StatelessWidget {
  const PostsList({super.key, required this.posts});
  final List<PostEntity> posts;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) => PostTile(post: posts[index]),
    );
  }
}