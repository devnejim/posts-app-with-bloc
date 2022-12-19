import 'package:bloc_app_example/features/posts/data/datasources/post_local.dart';
import 'package:bloc_app_example/features/posts/data/datasources/post_remote.dart';
import 'package:bloc_app_example/features/posts/data/repositories/post_repository_impl.dart';
import 'package:bloc_app_example/features/posts/domain/usecases/add.dart';
import 'package:bloc_app_example/features/posts/domain/usecases/delete.dart';
import 'package:bloc_app_example/features/posts/domain/usecases/get_all.dart';
import 'package:bloc_app_example/features/posts/domain/usecases/update.dart';
import 'package:bloc_app_example/features/posts/presentation/blocs/add_delete_update/add_delete_update_bloc.dart';
import 'package:bloc_app_example/features/posts/presentation/blocs/posts/posts_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/utils/network.dart';

GetIt getIt = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    // Bloc Services
    getIt.registerFactory(() => PostsBloc(getAllPostsUsecase: getIt()));
    getIt.registerFactory(() => AddDeleteUpdateBloc(
        addPostUsecase: getIt(),
        deletePostUsecase: getIt(),
        updatePostUsecase: getIt()));

    //UseCases
    getIt.registerLazySingleton(
        () => GetAllPostsUsecase(postRepository: getIt()));
    getIt.registerLazySingleton(() => AddPostUsecase(getIt()));
    getIt.registerLazySingleton(() => DeletePostUsecase(getIt()));
    getIt.registerLazySingleton(() => UpdatePostUsecase(getIt()));

    // Repo
    getIt.registerLazySingleton(() => PostRepositoryImpl(
        localDataSource: getIt(),
        remoteDataSource: getIt(),
        networkInfo: getIt()));

    // Data sources

    getIt.registerLazySingleton(
        () => PostsRemoteDataSourceImpl(client: getIt()));
    getIt.registerLazySingleton(
        () => PostsLocalDataSourceImpl(sharedPreferences: getIt()));

    //! Core

    getIt.registerLazySingleton(() => NetworkInfoImpl(getIt()));

//! External

    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);
    getIt.registerLazySingleton(() => http.Client());
    getIt.registerLazySingleton(() => InternetConnectionChecker());
  }
}
