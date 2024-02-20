import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

void updateAnimeData(Map animeDataMap){
  if(appStateRepo.globalAnimeData[animeDataMap['id']] != null){
    AnimeDataClass animeDataClass = appStateRepo.globalAnimeData[animeDataMap['id']]!.notifier.value;
    appStateRepo.globalAnimeData[animeDataClass.id]!.notifier.value = animeDataClass.fromMapUpdateAll(animeDataMap);
  }else{
    AnimeDataClass animeDataClass = AnimeDataClass.fetchNewInstance(animeDataMap['id']).fromMapUpdateAll(animeDataMap);
    final animeDataNotifier = ValueNotifier<AnimeDataClass>(
      animeDataClass
    );
    final animeDataNotifierWrapper = AnimeDataNotifier(animeDataClass.id, animeDataNotifier);
    appStateRepo.globalAnimeData[animeDataClass.id] = animeDataNotifierWrapper;
  }
}

void updateMangaData(Map mangaDataMap){
  if(appStateRepo.globalMangaData[mangaDataMap['id']] != null){
    MangaDataClass mangaDataClass = appStateRepo.globalMangaData[mangaDataMap['id']]!.notifier.value;
    appStateRepo.globalMangaData[mangaDataClass.id]!.notifier.value = mangaDataClass.fromMapUpdateAll(mangaDataMap);
  }else{
    MangaDataClass mangaDataClass = MangaDataClass.fetchNewInstance(mangaDataMap['id']).fromMapUpdateAll(mangaDataMap);
    final mangaDataNotifier = ValueNotifier<MangaDataClass>(
      mangaDataClass
    );
    final mangaDataNotifierWrapper = MangaDataNotifier(mangaDataClass.id, mangaDataNotifier);
    appStateRepo.globalMangaData[mangaDataClass.id] = mangaDataNotifierWrapper;
  }
}

void updateBasicCharacterData(Map characterDataMap){
  if(appStateRepo.globalCharacterData[characterDataMap['mal_id']] != null){
    CharacterDataClass characterDataClass = appStateRepo.globalCharacterData[characterDataMap['mal_id']]!.notifier.value;
    appStateRepo.globalCharacterData[characterDataClass.id]!.notifier.value = characterDataClass.fromMapUpdateBasic(characterDataMap);
  }else{
    CharacterDataClass characterDataClass = CharacterDataClass.fetchNewInstance(characterDataMap['mal_id']).fromMapUpdateBasic(characterDataMap);
    final characterDataNotifier = ValueNotifier<CharacterDataClass>(
      characterDataClass
    );
    final charaterDataNotifierWrapper = CharacterDataNotifier(characterDataClass.id, characterDataNotifier);
    appStateRepo.globalCharacterData[characterDataClass.id] = charaterDataNotifierWrapper;
  }
}

void updateCharacterData(Map characterDataMap){
  if(appStateRepo.globalCharacterData[characterDataMap['mal_id']] != null){
    CharacterDataClass characterDataClass = appStateRepo.globalCharacterData[characterDataMap['mal_id']]!.notifier.value;
    appStateRepo.globalCharacterData[characterDataClass.id]!.notifier.value = characterDataClass.fromMapUpdateAll(characterDataMap);
  }else{
    CharacterDataClass characterDataClass = CharacterDataClass.fetchNewInstance(characterDataMap['mal_id']).fromMapUpdateAll(characterDataMap);
    final characterDataNotifier = ValueNotifier<CharacterDataClass>(
      characterDataClass
    );
    final charaterDataNotifierWrapper = CharacterDataNotifier(characterDataClass.id, characterDataNotifier);
    appStateRepo.globalCharacterData[characterDataClass.id] = charaterDataNotifierWrapper;
  }
}