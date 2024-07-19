import 'package:anime_list_app/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void updateAnimeStatusFromMap(int id, Map? map) {
  if(map == null) {
    return;
  }
  
  AnimeMyListStatusClass animeDataClass = AnimeMyListStatusClass.fromMap(map);
  if(appStateRepo.globalAnimeData[id] != null){
    navigatorKey.currentContext?.read(appStateRepo.globalAnimeData[id]!.notifier).update(
      animeDataClass
    );
  }else{
    appStateRepo.globalAnimeData[id] = NotifierProvider<AnimeStatusNotifier, AnimeMyListStatusClass>(
      () => AnimeStatusNotifier()
    );
    navigatorKey.currentContext?.read(appStateRepo.globalAnimeData[id]!.notifier).update(
      animeDataClass
    );
  }
}

void updateAnimeStatusFromModel(int id, AnimeMyListStatusClass? model) {
  if(model == null) {
    return;
  }
  
  if(appStateRepo.globalAnimeData[id] != null){
    navigatorKey.currentContext?.read(appStateRepo.globalAnimeData[id]!.notifier).update(model);
  }else{
    appStateRepo.globalAnimeData[id] = NotifierProvider<AnimeStatusNotifier, AnimeMyListStatusClass>(
      () => AnimeStatusNotifier()
    );
    navigatorKey.currentContext?.read(appStateRepo.globalAnimeData[id]!.notifier).update(model);
  }
}

void updateMangaStatusFromMap(int id, Map? map) {
  if(map == null) {
    return;
  }
  
  MangaMyListStatusClass mangaDataClass = MangaMyListStatusClass.fromMap(map);
  if(appStateRepo.globalMangaData[id] != null){
    navigatorKey.currentContext?.read(appStateRepo.globalMangaData[id]!.notifier).update(
      mangaDataClass
    );
  }else{
    appStateRepo.globalMangaData[id] = NotifierProvider<MangaStatusNotifier, MangaMyListStatusClass>(
      () => MangaStatusNotifier()
    );
    navigatorKey.currentContext?.read(appStateRepo.globalMangaData[id]!.notifier).update(
      mangaDataClass
    );
  }
}

void updateMangaStatusFromModel(int id, MangaMyListStatusClass? model) {
  if(model == null) {
    return;
  }
  
  if(appStateRepo.globalMangaData[id] != null){
    navigatorKey.currentContext?.read(appStateRepo.globalMangaData[id]!.notifier).update(model);
  }else{
    appStateRepo.globalMangaData[id] = NotifierProvider<MangaStatusNotifier, MangaMyListStatusClass>(
      () => MangaStatusNotifier()
    );
    navigatorKey.currentContext?.read(appStateRepo.globalMangaData[id]!.notifier).update(model);
  }
}