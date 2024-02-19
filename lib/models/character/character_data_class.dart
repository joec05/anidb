import 'package:anime_list_app/global_files.dart';

class CharacterDataClass{
  int id;
  CharacterImageClass cover;
  String name;
  String? kanjiName;
  List<String> nicknames;
  int favouritedCount;
  String? about;
  List<CharacterAnimeClass> animes;
  List<CharacterMangaClass> mangas;
  List<CharacterVoiceClass> voices;

  CharacterDataClass(
    this.id,
    this.cover,
    this.name,
    this.kanjiName,
    this.nicknames,
    this.favouritedCount,
    this.about,
    this.animes,
    this.mangas, 
    this.voices
  );

  CharacterDataClass fromMapUpdateBasic(Map map){
    return CharacterDataClass(
      map['mal_id'], 
      CharacterImageClass(
        map['images']['jpg']['small_image_url'],
        map['images']['jpg']['image_url']
      ), 
      map['name'], 
      map['name_kanji'], 
      List<String>.from(map['nicknames']), 
      map['favorites'], 
      map['about'],
      animes, mangas, voices
    );
  }

  CharacterDataClass fromMapUpdateAll(Map map){
    return CharacterDataClass(
      map['mal_id'], 
      CharacterImageClass(
        map['images']['jpg']['small_image_url'],
        map['images']['jpg']['image_url']
      ), 
      map['name'], 
      map['name_kanji'], 
      List<String>.from(map['nicknames']), 
      map['favorites'], 
      map['about'], 
      List.generate(map['anime'].length, (i) => CharacterAnimeClass(
        map['anime'][i]['role'], 
        map['anime'][i]['anime']['mal_id'],
        AnimeImageClass(
          map['anime'][i]['anime']['images']['jpg']['small_image_url'],
          map['anime'][i]['anime']['images']['jpg']['image_url']
        ), 
        map['anime'][i]['anime']['title']
      )), 
      List.generate(map['manga'].length, (i) => CharacterMangaClass(
        map['manga'][i]['role'], 
        map['manga'][i]['manga']['mal_id'],
        MangaImageClass(
          map['manga'][i]['manga']['images']['jpg']['small_image_url'],
          map['manga'][i]['manga']['images']['jpg']['image_url']
        ), 
        map['manga'][i]['manga']['title']
      )),  
      List.generate(map['voices'].length, (i) => CharacterVoiceClass(
        map['voices'][i]['language'], 
        map['voices'][i]['person']['mal_id'],
        PersonImageClass(
          map['voices'][i]['person']['images']['jpg']['small_image_url'],
          map['voices'][i]['person']['images']['jpg']['image_url']
        ), 
        map['voices'][i]['person']['name']
      )), 
    );
  }

  factory CharacterDataClass.fetchNewInstance(int id){
    return CharacterDataClass(
      id, CharacterImageClass('', ''), '', '', [], 0, '', [], [], []
    );
  }
}