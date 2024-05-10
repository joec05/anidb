import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAnimeController {
  BuildContext context;
  late List<AutoDisposeAsyncNotifierProvider<MyAnimeListNotifier, UserAnimeListStatusClass>> statusNotifiers = [];
  late StreamSubscription updateUserAnimeListStreamClassSubscription;

  UserAnimeController(
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    statusNotifiers = [
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          context,
          UserAnimeListStatusClass(
            [], 'watching', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          context,
          UserAnimeListStatusClass(
            [], 'plan_to_watch', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          context,
          UserAnimeListStatusClass(
            [], 'completed', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          context,
          UserAnimeListStatusClass(
            [], 'dropped', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyAnimeListNotifier, UserAnimeListStatusClass>(() => 
        MyAnimeListNotifier(
          context,
          UserAnimeListStatusClass(
            [], 'on_hold', false, PaginationStatus.loaded
          )
        )
      ),
    ];
    updateUserAnimeListStreamClassSubscription = UpdateUserAnimeListStreamClass().userAnimeListStream.listen((UserAnimeListStreamControllerClass data) {
      if(mounted){
        AnimeDataClass animeData = data.animeData;
        int id = animeData.id;
        if(context.mounted) {
          AnimeMyListStatusClass? myAnimeStatus = context.read(appStateRepo.globalAnimeData[id]!.notifier).getState();
          String? status = myAnimeStatus.status;
          if(mounted) {
            for(int i = 0; i < statusNotifiers.length; i++) {
              context.read(statusNotifiers[i].notifier).removeByIDAndAddByStatus(
                id, status, data.animeData
              );
            }
          }
        }
      }
    });
  }

  void dispose(){
    updateUserAnimeListStreamClassSubscription.cancel();
  }  
}

class MyAnimeListNotifier extends AutoDisposeAsyncNotifier<UserAnimeListStatusClass> {
  final BuildContext context;
  UserAnimeListStatusClass statusClass;
  late AnimeRepository animeRepository;

  MyAnimeListNotifier(
    this.context,
    this.statusClass
  );

  @override
  FutureOr<UserAnimeListStatusClass> build() async {
    state = const AsyncLoading();
    animeRepository = AnimeRepository(context);
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

  void removeByIDAndAddByStatus(int id, String? status, AnimeDataClass animeData) {
    int index = statusClass.animeList.indexWhere((e) => e.id == id);
    if(index > -1) {
      statusClass.animeList.removeAt(index);
      state = AsyncData(statusClass);
    }
    if(status == statusClass.status) {
      statusClass.animeList.insert(0, animeData);
      statusClass.animeList.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  Future<void> refresh() async => await build();
}