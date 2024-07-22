import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAnimeController {
  late List<AutoDisposeAsyncNotifierProvider<MyAnimeListNotifier, UserAnimeListStatusClass>> statusNotifiers = [];
  late StreamSubscription updateUserAnimeListStreamClassSubscription;

  void initialize() {
    statusNotifiers = [
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          UserAnimeListStatusClass(
            [], 'watching', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          UserAnimeListStatusClass(
            [], 'plan_to_watch', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          UserAnimeListStatusClass(
            [], 'completed', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          UserAnimeListStatusClass(
            [], 'dropped', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          UserAnimeListStatusClass(
            [], 'on_hold', false, PaginationStatus.loaded
          )
        )
      ),
    ];
    updateUserAnimeListStreamClassSubscription = UpdateUserAnimeListStreamClass().userAnimeListStream.listen((UserAnimeListStreamControllerClass data) {
      if(data.oldStatus != data.newStatus) {
        AnimeDataClass animeData = data.animeData;
        for(int i = 0; i < statusNotifiers.length; i++) {
          final UserAnimeListStatusClass? statusClass = navigatorKey.currentContext?.read(statusNotifiers[i].notifier).statusClass;
          String? status = statusClass?.status;
          navigatorKey.currentContext?.read(statusNotifiers[i].notifier).removeByIDAndAdd(
            status, data.oldStatus, data.newStatus, animeData
          );
        }
      }
    });
  }

  void dispose(){
    updateUserAnimeListStreamClassSubscription.cancel();
  }  
}

class MyAnimeListNotifier extends AutoDisposeAsyncNotifier<UserAnimeListStatusClass> {
  UserAnimeListStatusClass statusClass;

  MyAnimeListNotifier(
    this.statusClass
  );

  @override
  FutureOr<UserAnimeListStatusClass> build() async {
    state = const AsyncLoading();
    APIResponseModel response = await animeRepository.fetchMyAnimesList(statusClass);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      statusClass = response.data;
      state = AsyncData(statusClass);
    }
    return statusClass;
  }

  Future<UserAnimeListStatusClass> paginate() async {
    state = AsyncData(statusClass.updatePaginationStatus(PaginationStatus.loading));
    APIResponseModel response = await animeRepository.fetchMyAnimesList(statusClass);
    if(response.error != null) {
      state = AsyncData(statusClass.updatePaginationStatus(PaginationStatus.loaded));
      state = AsyncError(response.error!.object, response.error!.stackTrace);
    } else {
      statusClass = response.data;
      statusClass = statusClass.updatePaginationStatus(PaginationStatus.loaded);
      state = AsyncData(statusClass);
    }
    return statusClass;
  }

  void removeByIDAndAdd(String? status, String? oldStatus, String? newStatus, AnimeDataClass animeData) {
    if(oldStatus == status) {
      statusClass.animeList.removeWhere((e) => e.id == animeData.id);
      state = AsyncData(statusClass);
    }
    if(newStatus == status) {
      statusClass.animeList.insert(0, animeData);
      statusClass.animeList.sort((a, b) => a.title.compareTo(b.title));
      state = AsyncData(statusClass);
    }
  }

  Future<void> refresh() async => await build();
}