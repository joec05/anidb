import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class UserMangaController {
  BuildContext context;
  ValueNotifier<UserMangaListStatusClass> reading = ValueNotifier(
    UserMangaListStatusClass(
      [], 'reading', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserMangaListStatusClass> planning = ValueNotifier(
    UserMangaListStatusClass(
      [], 'plan_to_read', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserMangaListStatusClass> completed = ValueNotifier(
    UserMangaListStatusClass(
      [], 'completed', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserMangaListStatusClass> dropped = ValueNotifier(
    UserMangaListStatusClass(
      [], 'dropped', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserMangaListStatusClass> onHold = ValueNotifier(
    UserMangaListStatusClass(
      [], 'on_hold', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  late StreamSubscription updateUserMangaListStreamClassSubscription;

  UserMangaController(
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController(){
    fetchUserMangasList(reading);
    fetchUserMangasList(planning);
    fetchUserMangasList(completed);
    fetchUserMangasList(dropped);
    fetchUserMangasList(onHold);
    updateUserMangaListStreamClassSubscription = UpdateUserMangaListStreamClass().userMangaListStream.listen((UserMangaListStreamControllerClass data) {
      if(mounted){
        int id = data.mangaData.id;
        String status = data.mangaData.myListStatus!.status!; 

        if(mounted) {
          reading.value.mangasList.remove(id);
          planning.value.mangasList.remove(id);
          completed.value.mangasList.remove(id);
          dropped.value.mangasList.remove(id);
          onHold.value.mangasList.remove(id);

          if(status == 'reading'){
            reading.value.mangasList.insert(0, id);
          }else if(status == 'plan_to_read'){
            planning.value.mangasList.insert(0, id);
          }else if(status == 'completed'){
            completed.value.mangasList.insert(0, id);
          }else if(status == 'dropped'){
            dropped.value.mangasList.insert(0, id);
          }else if(status == 'on_hold'){
            onHold.value.mangasList.insert(0, id);
          }

          reading.value = reading.value.copy();
          planning.value = planning.value.copy();
          completed.value = completed.value.copy();
          onHold.value = onHold.value.copy();
          dropped.value = dropped.value.copy();
        }
      }
    });
  }

  void dispose(){
    updateUserMangaListStreamClassSubscription.cancel();
    isLoading.dispose();
    reading.dispose();
    planning.dispose();
    completed.dispose();
    onHold.dispose();
    dropped.dispose();
  }

  void fetchUserMangasList(ValueNotifier<UserMangaListStatusClass> statusClass) async{
    if(mounted){
      if(!isLoading.value){
        statusClass.value = statusClass.value.updatePaginationStatus(PaginationStatus.loading);
      }
    }
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/mangalist?status=${statusClass.value.status}&offset=${statusClass.value.mangasList.length}&limit=$userDisplayFetchLimit&$fetchAllMangaFieldsStr',
      {}
    );
    if(res != null) {
      statusClass.value = statusClass.value.updateCanPaginate((res['paging']['next'] != null));
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateMangaData(data[i]['node']);
          int id = data[i]['node']['id'];
          if(appStateRepo.globalMangaData[id] != null){
            if(appStateRepo.globalMangaData[id]!.notifier.value.myListStatus != null){
              String? status = appStateRepo.globalMangaData[id]!.notifier.value.myListStatus!.status;
              if(status == 'reading'){
                reading.value.mangasList.add(id);
              }else if(status == 'plan_to_read'){
                planning.value.mangasList.add(id);
              }else if(status == 'completed'){
                completed.value.mangasList.add(id);
              }else if(status == 'on_hold'){
                onHold.value.mangasList.add(id);
              }else if(status == 'dropped'){
                dropped.value.mangasList.add(id);
              }
            }
          }
        }
        
        reading.value = reading.value.copy();
        planning.value = planning.value.copy();
        completed.value = completed.value.copy();
        onHold.value = onHold.value.copy();
        dropped.value = dropped.value.copy();

        if(isLoading.value){
          isLoading.value = false;
        }else{
          statusClass.value = statusClass.value.updatePaginationStatus(PaginationStatus.loaded);
        }
      }
    }
  }
}