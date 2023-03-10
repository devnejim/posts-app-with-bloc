import 'package:bloc_app_example/core/errors/app_exceptions.dart';
import 'package:bloc_app_example/core/utils/network.dart';
import 'package:bloc_app_example/features/posts/data/datasources/post_local.dart';
import 'package:bloc_app_example/features/posts/data/models/post.dart';
import 'package:bloc_app_example/features/posts/domain/entities/post.dart';
import 'package:bloc_app_example/core/errors/app_failures.dart';
import 'package:bloc_app_example/features/posts/domain/entities/post_comment.dart';
import 'package:bloc_app_example/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/post_remote.dart';

typedef PostCRUD = Future<Unit>;

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final PostsLocalDataSource localDataSource;
  final PostsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts(
      int start, int limit) async {
    if ((await networkInfo.connectionStatus)) {
      try {
        final posts = await remoteDataSource.getPosts(start, limit);
        localDataSource.cachePosts(posts);
        return Right(posts);
      } on OfflineException {
        return Left(OfflineFailure());
      } on ServerException {
        return Left(ServerFailure());
      } catch (_) {
        return Left(UnExpectedFailure());
      }
    } else {
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        return Right(cachedPosts);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> addPost(PostEntity post) async {
    return await _defineDataSourceAndAction(
        remoteDataSource.addPost(PostModel.fromEntity(post)));
  }

  @override
  Future<Either<Failure, Unit>> deletePost(int id) async {
    return await _defineDataSourceAndAction(remoteDataSource.deletePost(id));
  }

  @override
  Future<Either<Failure, Unit>> updatePost(PostEntity post) async {
    return await _defineDataSourceAndAction(
        remoteDataSource.updatePost(PostModel.fromEntity(post)));
  }

  @override
  Future<Either<Failure, List<PostCommentEntity>>> getPostComments(
      int id) async {
    if ((await networkInfo.connectionStatus)) {
      try {
        final postComments = await remoteDataSource.getPostComments(id);
        // TODO implement cache comments
        // localDataSource.cachePostComments(id, postComments);
        return Right(postComments);
      } on OfflineException {
        return Left(OfflineFailure());
      } on ServerException {
        return Left(ServerFailure());
      } catch (_) {
        return Left(UnExpectedFailure());
      }
    } else {
      try {
        final cachedComments = await localDataSource.getPostCachedComments(id);
        return Right(cachedComments);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      } catch (_) {
        return Left(UnExpectedFailure());
      }
    }
  }

  Future<Either<Failure, Unit>> _defineDataSourceAndAction(
      PostCRUD postCRUD) async {
    if ((await networkInfo.connectionStatus)) {
      try {
        await postCRUD;
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnExpectedFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
  // TODO: implement generic function to clean code
  // Future<T> _defineDataSourceAndActionGeneric<T>(T) {
  //   return Future.error('rrrrrrrrrrrrrrrrrrrrr');
  // }
}
