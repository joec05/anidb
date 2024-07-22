import 'dart:async';
import 'package:anidb_app/global_files.dart';
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
      if(data.oldStatus != data.newStatus) {
        MangaDataClass mangaData = data.mangaData;
        for(int i = 0; i < statusNotifiers.length; i++) {
          final UserMangaListStatusClass? statusClass = navigatorKey.currentContext?.read(statusNotifiers[i].notifier).statusClass;
          String? status = statusClass?.status;
          navigatorKey.currentContext?.read(statusNotifiers[i].notifier).removeByIDAndAdd(
            status, data.oldStatus, data.newStatus, mangaData
          );
        }
      }
    });
  }

  void dispose(){
    updateUserMangaListStreamClassSubscription.cancel();
  }
}

class MyMangaListNotifier extends AutoDisposeAsyncNotifier<UserMangaListStatusClass> {
  UserMangaListStatusClass statusClass;

  MyMangaListNotifier(
    this.statusClass
  );

  @override
  FutureOr<UserMangaListStatusClass> build() async {
    state = const AsyncLoading();
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

  void removeByIDAndAdd(String? status, String? oldStatus, String? newStatus, MangaDataClass mangaData) {
    if(oldStatus == status) {
      statusClass.mangaList.removeWhere((e) => e.id == mangaData.id);
      state = AsyncData(statusClass);
    }
    if(newStatus == status) {
      statusClass.mangaList.insert(0, mangaData);
      statusClass.mangaList.sort((a, b) => a.title.compareTo(b.title));
      state = AsyncData(statusClass);
    }
  }

  Future<void> refresh() async => await build();
}