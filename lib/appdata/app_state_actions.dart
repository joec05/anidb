import 'package:anime_list_app/class/anime_data_class.dart';
import 'package:anime_list_app/class/anime_data_notifier.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/class/character_data_notifier.dart';
import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:anime_list_app/class/manga_data_notifier.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:flutter/material.dart';

void updateAnimeData(Map animeDataMap){
  if(appStateClass.globalAnimeData[animeDataMap['id']] != null){
    AnimeDataClass animeDataClass = appStateClass.globalAnimeData[animeDataMap['id']]!.notifier.value;
    appStateClass.globalAnimeData[animeDataClass.id]!.notifier.value = animeDataClass.fromMapUpdateAll(animeDataMap);
  }else{
    AnimeDataClass animeDataClass = AnimeDataClass.fetchNewInstance(animeDataMap['id']).fromMapUpdateAll(animeDataMap);
    final animeDataNotifier = ValueNotifier<AnimeDataClass>(
      animeDataClass
    );
    final animeDataNotifierWrapper = AnimeDataNotifier(animeDataClass.id, animeDataNotifier);
    appStateClass.globalAnimeData[animeDataClass.id] = animeDataNotifierWrapper;
  }
}

void updateMangaData(Map mangaDataMap){
  if(appStateClass.globalMangaData[mangaDataMap['id']] != null){
    MangaDataClass mangaDataClass = appStateClass.globalMangaData[mangaDataMap['id']]!.notifier.value;
    appStateClass.globalMangaData[mangaDataClass.id]!.notifier.value = mangaDataClass.fromMapUpdateAll(mangaDataMap);
  }else{
    MangaDataClass mangaDataClass = MangaDataClass.fetchNewInstance(mangaDataMap['id']).fromMapUpdateAll(mangaDataMap);
    final mangaDataNotifier = ValueNotifier<MangaDataClass>(
      mangaDataClass
    );
    final mangaDataNotifierWrapper = MangaDataNotifier(mangaDataClass.id, mangaDataNotifier);
    appStateClass.globalMangaData[mangaDataClass.id] = mangaDataNotifierWrapper;
  }
}

void updateBasicCharacterData(Map characterDataMap){
  if(appStateClass.globalCharacterData[characterDataMap['mal_id']] != null){
    CharacterDataClass characterDataClass = appStateClass.globalCharacterData[characterDataMap['mal_id']]!.notifier.value;
    appStateClass.globalCharacterData[characterDataClass.id]!.notifier.value = characterDataClass.fromMapUpdateBasic(characterDataMap);
  }else{
    CharacterDataClass characterDataClass = CharacterDataClass.fetchNewInstance(characterDataMap['mal_id']).fromMapUpdateBasic(characterDataMap);
    final characterDataNotifier = ValueNotifier<CharacterDataClass>(
      characterDataClass
    );
    final charaterDataNotifierWrapper = CharacterDataNotifier(characterDataClass.id, characterDataNotifier);
    appStateClass.globalCharacterData[characterDataClass.id] = charaterDataNotifierWrapper;
  }
}

void updateCharacterData(Map characterDataMap){
  if(appStateClass.globalCharacterData[characterDataMap['mal_id']] != null){
    CharacterDataClass characterDataClass = appStateClass.globalCharacterData[characterDataMap['mal_id']]!.notifier.value;
    appStateClass.globalCharacterData[characterDataClass.id]!.notifier.value = characterDataClass.fromMapUpdateAll(characterDataMap);
  }else{
    CharacterDataClass characterDataClass = CharacterDataClass.fetchNewInstance(characterDataMap['mal_id']).fromMapUpdateAll(characterDataMap);
    final characterDataNotifier = ValueNotifier<CharacterDataClass>(
      characterDataClass
    );
    final charaterDataNotifierWrapper = CharacterDataNotifier(characterDataClass.id, characterDataNotifier);
    appStateClass.globalCharacterData[characterDataClass.id] = charaterDataNotifierWrapper;
  }
}