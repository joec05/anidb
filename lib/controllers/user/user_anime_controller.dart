import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';


class UserAnimeController {
  BuildContext context;
  ValueNotifier<UserAnimeListStatusClass> watching = ValueNotifier(
    UserAnimeListStatusClass(
      [], 'watching', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserAnimeListStatusClass> planning = ValueNotifier(
    UserAnimeListStatusClass(
      [], 'plan_to_watch', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserAnimeListStatusClass> completed = ValueNotifier(
    UserAnimeListStatusClass(
      [], 'completed', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserAnimeListStatusClass> dropped = ValueNotifier(
    UserAnimeListStatusClass(
      [], 'dropped', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<UserAnimeListStatusClass> onHold = ValueNotifier(
    UserAnimeListStatusClass(
      [], 'on_hold', false, PaginationStatus.loaded
    )
  );
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  late StreamSubscription updateUserAnimeListStreamClassSubscription;

  UserAnimeController(
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchUserAnimesList(watching);
    fetchUserAnimesList(planning);
    fetchUserAnimesList(completed);
    fetchUserAnimesList(dropped);
    fetchUserAnimesList(onHold);
    updateUserAnimeListStreamClassSubscription = UpdateUserAnimeListStreamClass().userAnimeListStream.listen((UserAnimeListStreamControllerClass data) {
      if(mounted){
        int id = data.animeData.id;
        String status = data.animeData.myListStatus!.status!; 

        if(mounted) {
          watching.value.animesList.remove(id);
          planning.value.animesList.remove(id);
          completed.value.animesList.remove(id);
          dropped.value.animesList.remove(id);
          onHold.value.animesList.remove(id);

          if(status == 'watching'){
            watching.value.animesList.insert(0, id);
            watching.value.animesList.sort((a, b) => appStateRepo.globalAnimeData[a]!.notifier.value.title.compareTo(appStateRepo.globalAnimeData[b]!.notifier.value.title));
          }else if(status == 'plan_to_watch'){
            planning.value.animesList.insert(0, id);
            planning.value.animesList.sort((a, b) => appStateRepo.globalAnimeData[a]!.notifier.value.title.compareTo(appStateRepo.globalAnimeData[b]!.notifier.value.title));
          }else if(status == 'completed'){
            completed.value.animesList.insert(0, id);
            completed.value.animesList.sort((a, b) => appStateRepo.globalAnimeData[a]!.notifier.value.title.compareTo(appStateRepo.globalAnimeData[b]!.notifier.value.title));
          }else if(status == 'dropped'){
            dropped.value.animesList.insert(0, id);
            dropped.value.animesList.sort((a, b) => appStateRepo.globalAnimeData[a]!.notifier.value.title.compareTo(appStateRepo.globalAnimeData[b]!.notifier.value.title));
          }else if(status == 'on_hold'){
            onHold.value.animesList.insert(0, id);
            onHold.value.animesList.sort((a, b) => appStateRepo.globalAnimeData[a]!.notifier.value.title.compareTo(appStateRepo.globalAnimeData[b]!.notifier.value.title));
          }

          watching.value = watching.value.copy();
          planning.value = planning.value.copy();
          completed.value = completed.value.copy();
          onHold.value = onHold.value.copy();
          dropped.value = dropped.value.copy();
        }
      }
    });
  }

  void dispose(){
    updateUserAnimeListStreamClassSubscription.cancel();
    isLoading.dispose();
    watching.dispose();
    planning.dispose();
    completed.dispose();
    onHold.dispose();
    dropped.dispose();
  }
  
  void fetchUserAnimesList(ValueNotifier<UserAnimeListStatusClass> statusClass) async{
    if(mounted){
      if(!isLoading.value){
        statusClass.value = statusClass.value.updatePaginationStatus(PaginationStatus.loading);
      }
    }
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me/animelist?status=${statusClass.value.status}&offset=${statusClass.value.animesList.length}&limit=$userDisplayFetchLimit&$fetchAllAnimeFieldsStr',
      {}
    );
    if(res != null) {
      statusClass.value = statusClass.value.updateCanPaginate((res['paging']['next'] != null));
      var data = res['data'];
      if(mounted) {
        for(int i = 0; i < data.length; i++){
          updateAnimeData(data[i]['node']);
          int id = data[i]['node']['id'];
          if(appStateRepo.globalAnimeData[id] != null){
            if(appStateRepo.globalAnimeData[id]!.notifier.value.myListStatus != null){
              String? status = appStateRepo.globalAnimeData[id]!.notifier.value.myListStatus!.status;
              if(status == 'watching'){
                watching.value.animesList.add(id);
              }else if(status == 'plan_to_watch'){
                planning.value.animesList.add(id);
              }else if(status == 'completed'){
                completed.value.animesList.add(id);
              }else if(status == 'on_hold'){
                onHold.value.animesList.add(id);
              }else if(status == 'dropped'){
                dropped.value.animesList.add(id);
              }
            }
          }
        }
        watching.value = watching.value.copy();
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