import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void updateAnimeStatusFromMap(BuildContext context, int id, Map? map) {
  if(map == null) {
    return;
  }
  
  AnimeMyListStatusClass animeDataClass = AnimeMyListStatusClass.fromMap(map);
  if(appStateRepo.globalAnimeData[id] != null){
    context.read(appStateRepo.globalAnimeData[id]!.notifier).update(
      animeDataClass
    );
  }else{
    appStateRepo.globalAnimeData[id] = NotifierProvider<AnimeStatusNotifier, AnimeMyListStatusClass>(
      () => AnimeStatusNotifier()
    );
    context.read(appStateRepo.globalAnimeData[id]!.notifier).update(
      animeDataClass
    );
  }
}

void updateAnimeStatusFromModel(BuildContext context, int id, AnimeMyListStatusClass? model) {
  if(model == null) {
    return;
  }
  
  if(appStateRepo.globalAnimeData[id] != null){
    context.read(appStateRepo.globalAnimeData[id]!.notifier).update(model);
  }else{
    appStateRepo.globalAnimeData[id] = NotifierProvider<AnimeStatusNotifier, AnimeMyListStatusClass>(
      () => AnimeStatusNotifier()
    );
    context.read(appStateRepo.globalAnimeData[id]!.notifier).update(model);
  }
}

void updateMangaStatusFromMap(BuildContext context, int id, Map? map) {
  if(map == null) {
    return;
  }
  
  MangaMyListStatusClass mangaDataClass = MangaMyListStatusClass.fromMap(map);
  if(appStateRepo.globalMangaData[id] != null){
    context.read(appStateRepo.globalMangaData[id]!.notifier).update(
      mangaDataClass
    );
  }else{
    appStateRepo.globalMangaData[id] = NotifierProvider<MangaStatusNotifier, MangaMyListStatusClass>(
      () => MangaStatusNotifier()
    );
    context.read(appStateRepo.globalMangaData[id]!.notifier).update(
      mangaDataClass
    );
  }
}

void updateMangaStatusFromModel(BuildContext context, int id, MangaMyListStatusClass? model) {
  if(model == null) {
    return;
  }
  
  if(appStateRepo.globalMangaData[id] != null){
    context.read(appStateRepo.globalMangaData[id]!.notifier).update(model);
  }else{
    appStateRepo.globalMangaData[id] = NotifierProvider<MangaStatusNotifier, MangaMyListStatusClass>(
      () => MangaStatusNotifier()
    );
    context.read(appStateRepo.globalMangaData[id]!.notifier).update(model);
  }
}