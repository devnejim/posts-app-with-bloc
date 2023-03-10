import 'package:bloc_app_example/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/app_failures.dart';
import '../entities/post.dart';

class GetAllPostsUsecase {
  GetAllPostsUsecase({
    required this.postRepository,
  });
  final PostRepository postRepository;
  // made callable class with getPosts Functionallity
  Future<Either<Failure, List<PostEntity>>> call(int start, int limit) async {
    final posts = await postRepository.getPosts(start, limit);
    return posts;
  }
}
