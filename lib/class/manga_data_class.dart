import 'package:anime_list_app/class/anime_image_class.dart';
import 'package:anime_list_app/class/character_data_class.dart';
import 'package:anime_list_app/class/manga_alternative_titles_class.dart';
import 'package:anime_list_app/class/manga_author_class.dart';
import 'package:anime_list_app/class/manga_my_list_status_class.dart';
import 'package:anime_list_app/class/manga_serialization_class.dart';
import 'package:anime_list_app/class/manga_statistics_class.dart';
import 'package:anime_list_app/class/recommended_manga_class.dart';
import 'package:anime_list_app/class/related_anime_class.dart';
import 'package:anime_list_app/class/related_manga_class.dart';
import 'package:anime_list_app/class/manga_image_class.dart';
import 'package:anime_list_app/class/manga_genre_class.dart';

class MangaDataClass{
  int id;
  String title;
  MangaImageClass? cover;
  MangaAlternativeTitlesClass? alternativeTitles;
  String? startDate;
  String? endDate;
  String? synopsis;
  double? mean;
  int? rank;
  int? popularity;
  int listedCount;
  int scoredCount;
  String? nsfw;
  List<MangaGenreClass> genres;
  String creationTime;
  String updatedTime;
  String mediaType;
  String status;
  MangaMyListStatusClass? myListStatus;
  int totalVolumes;
  int totalChapters;
  List<MangaAuthorClass> authors;
  List<MangaImageClass> pictures;
  String? background;
  List<CharacterDataClass> characters;
  List<RelatedAnimeClass> relatedAnimes;
  List<RelatedMangaClass> relatedMangas;
  List<RecommendedMangaClass> recommendations;
  List<MangaSerializationClass> serializations;
  MangaStatisticsClass statistics;

  MangaDataClass(
    this.id,
    this.title,
    this.cover,
    this.alternativeTitles,
    this.startDate,
    this.endDate,
    this.synopsis,
    this.mean,
    this.rank,
    this.popularity,
    this.listedCount,
    this.scoredCount,
    this.nsfw,
    this.genres,
    this.creationTime,
    this.updatedTime,
    this.mediaType,
    this.status,
    this.myListStatus,
    this.totalVolumes,
    this.totalChapters,
    this.authors,
    this.pictures,
    this.background,
    this.characters,
    this.relatedAnimes,
    this.relatedMangas,
    this.recommendations,
    this.serializations,
    this.statistics
  );

  MangaDataClass fromMapUpdateAll(Map map){
    return MangaDataClass(
      map['id'], map['title'], 
      map['main_picture'] != null ? 
        MangaImageClass(map['main_picture']['medium'], map['main_picture']['large'])
      : null,
      map['alternative_titles'] != null ?
        MangaAlternativeTitlesClass(
          map['alternative_titles']['synonyms'] != null ? List<String>.from(map['alternative_titles']['synonyms']) : null, 
          map['alternative_titles']['en'], 
          map['alternative_titles']['ja']
        )
      : null, 
      map['start_date'], 
      map['end_date'], 
      map['synopsis'], 
      map['mean'] is int ? map['mean'].toDouble() : map['mean'], 
      map['rank'], 
      map['popularity'], 
      map['num_list_users'], 
      map['num_scoring_users'], 
      map['nsfw'], 
      map['genres'] == null ? [] 
      : List.generate(map['genres'].length, (i) => MangaGenreClass(
        map['genres'][i]['id'], map['genres'][i]['name']
      )),
      map['created_at'], 
      map['updated_at'], 
      map['media_type'], 
      map['status'], 
      map['my_list_status'] != null ? MangaMyListStatusClass.fromMap(map['my_list_status']) : null,
      map['num_volumes'], map['num_chapters'], 
      map['authors'] == null ? [] : List.generate(map['authors'].length, (i) => MangaAuthorClass(
        map['authors'][i]['node']['id'], 
        map['authors'][i]['node']['first_name'], 
        map['authors'][i]['node']['last_name'], 
        map['authors'][i]['role']
      )), 
      map['pictures'] == null ? pictures :
      List.generate(map['pictures'].length, (i) => MangaImageClass(
        map['pictures'][i]['medium'], 
        map['pictures'][i]['large']
      )), 
      map['background'] ?? background, 
      characters,
      map['related_anime'] == null ? relatedAnimes :
      List.generate(map['related_anime'].length, (i) => RelatedAnimeClass(
        map['related_anime'][i]['node']['id'], 
        map['related_anime'][i]['node']['title'], 
        AnimeImageClass(
          map['related_anime'][i]['node']['main_picture']['medium'], 
          map['related_anime'][i]['node']['main_picture']['large']
        ), 
        map['related_anime'][i]['relation_type_formatted']
      )),
      map['related_manga'] == null ? relatedMangas :
      List.generate(map['related_manga'].length, (i) => RelatedMangaClass(
        map['related_manga'][i]['node']['id'], 
        map['related_manga'][i]['node']['title'], 
        MangaImageClass(
          map['related_manga'][i]['node']['main_picture']['medium'], 
          map['related_manga'][i]['node']['main_picture']['large']
        ), 
        map['related_manga'][i]['relation_type_formatted']
      )), 
      map['recommendations'] == null ? recommendations :
      List.generate(map['recommendations'].length, (i) => RecommendedMangaClass(
        map['recommendations'][i]['node']['id'], 
        map['recommendations'][i]['node']['title'], 
        MangaImageClass(
          map['recommendations'][i]['node']['main_picture']['medium'], 
          map['recommendations'][i]['node']['main_picture']['large']
        ),
        map['recommendations'][i]['num_recommendations']
      )),
      map['serialization'] == null ? serializations :
      List.generate(map['serialization'].length, (i) => MangaSerializationClass(
        map['serialization'][i]['node']['id'], 
        map['serialization'][i]['node']['name'], 
        map['serialization'][i]['role']
      )),
      statistics
    );
  }

  factory MangaDataClass.fetchNewInstance(int id){
    return MangaDataClass(
      id, '', MangaImageClass('', ''), MangaAlternativeTitlesClass([], '', ''),
      null, null, null, null, null, null, 0, 0, null, [], '', '', '', '', 
      MangaMyListStatusClass('', 0, 0, 0, false, '', '', [], ''), 0, 0,
      [], [], null, [], [], [], [], [], MangaStatisticsClass(0, 0, 0, 0, 0)
    );
  }

  factory MangaDataClass.generateNewCopy(MangaDataClass mangaData){
    return MangaDataClass(
      mangaData.id,
      mangaData.title,
      mangaData.cover,
      mangaData.alternativeTitles,
      mangaData.startDate,
      mangaData.endDate,
      mangaData.synopsis,
      mangaData.mean,
      mangaData.rank,
      mangaData.popularity,
      mangaData.listedCount,
      mangaData.scoredCount,
      mangaData.nsfw,
      mangaData.genres,
      mangaData.creationTime,
      mangaData.updatedTime,
      mangaData.mediaType,
      mangaData.status,
      mangaData.myListStatus,
      mangaData.totalVolumes,
      mangaData.totalChapters,
      mangaData.authors,
      mangaData.pictures,
      mangaData.background,
      mangaData.characters,
      mangaData.relatedAnimes,
      mangaData.relatedMangas,
      mangaData.recommendations,
      mangaData.serializations,
      mangaData.statistics
    );
  }
}