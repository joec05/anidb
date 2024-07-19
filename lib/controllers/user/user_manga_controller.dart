import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserMangaController {
  late List<AutoDisposeAsyncNotifierProvider<MyMangaListNotifier, UserMangaListStatusClass>> statusNotifiers = [];
  late StreamSubscription updateUserMangaListStreamClassSubscription;

  void initialize(){
    statusNotifiers = [
      AsyncNotifierProvider.autoDispose<MyMangaListNotifier, UserMangaListStatusClass>(() => 
        MyMangaListNotifier(
          UserMangaListStatusClass(
            [], 'reading', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyMangaListNotifier, UserMangaListStatusClass>(() => 
        MyMangaListNotifier(
          UserMangaListStatusClass(
            [], 'plan_to_read', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyMangaListNotifier, UserMangaListStatusClass>(() => 
        MyMangaListNotifier(
          UserMangaListStatusClass(
            [], 'completed', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyMangaListNotifier, UserMangaListStatusClass>(() => 
        MyMangaListNotifier(
          UserMangaListStatusClass(
            [], 'dropped', false, PaginationStatus.loaded
          )
        )
      ),
      AsyncNotifierProvider.autoDispose<MyMangaListNotifier, UserMangaListStatusClass>(() => 
        MyMangaListNotifier(
          UserMangaListStatusClass(
            [], 'on_hold', false, PaginationStatus.loaded
          )
        )
      ),
    ];
    updateUserMangaListStreamClassSubscription = UpdateUserMangaListStreamClass().userMangaListStream.listen((UserMangaListStreamControllerClass data) {
      int id = data.mangaData.id;
      MangaMyListStatusClass? myMangaStatus = navigatorKey.currentContext?.read(appStateRepo.globalMangaData[id]!.notifier).getState();
      String? status = myMangaStatus?.status;
      for(int i = 0; i < statusNotifiers.length; i++) {
        navigatorKey.currentContext?.read(statusNotifiers[i].notifier).removeByIDAndAddByStatus(
          id, status, data.mangaData
        );
      }
    });
  }

  void dispose(){
    updateUserMangaListStreamClassSubscription.cancel();
  }
}

class MyMangaListNotifier extends AutoDisposeAsyncNotifier<UserMangaListStatusClass> {
  UserMangaListStatusClass statusClass;
  late MangaRepository mangaRepository;

  MyMangaListNotifier(
    this.statusClass
  );

  @override
  FutureOr<UserMangaListStatusClass> build() async {
    state = const AsyncLoading();
    mangaRepository = MangaRepository();
    APIResponseModel response = await mangaRepository.fetchMyMangasList(statusClass);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      statusClass = response.data;
      state = AsyncData(statusClass);
    }
    return statusClass;
  }

  Future<UserMangaListStatusClass> paginate() async {
    state = AsyncData(statusClass.updatePaginationStatus(PaginationStatus.loading));
    APIResponseModel response = await mangaRepository.fetchMyMangasList(statusClass);
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

  void removeByIDAndAddByStatus(int id, String? status, MangaDataClass mangaData) {
    int index = statusClass.mangaList.indexWhere((e) => e.id == id);
    if(index > -1) {
      statusClass.mangaList.removeAt(index);
      state = AsyncData(statusClass.copy());
    }
    if(status == statusClass.status) {
      statusClass.mangaList.insert(0, mangaData);
      statusClass.mangaList.sort((a, b) => a.title.compareTo(b.title));
      state = AsyncData(statusClass.copy());
    }
  }

  Future<void> refresh() async => await build();
}