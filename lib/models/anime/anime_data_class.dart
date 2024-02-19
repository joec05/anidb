import 'package:anime_list_app/global_files.dart';

class AnimeDataClass {
  int id;
  String title;
  AnimeImageClass? cover;
  AnimeAlternativeTitlesClass? alternativeTitles;
  String? startDate;
  String? endDate;
  String? synopsis;
  double? mean;
  int? rank;
  int? popularity;
  int listedCount;
  int scoredCount;
  String? nsfw;
  List<AnimeGenreClass> genres;
  String creationTime;
  String updatedTime;
  String mediaType;
  String status;
  AnimeMyListStatusClass? myListStatus;
  int totalEpisodes;
  AnimeStartSeasonClass? startSeason;
  AnimeBroadcastClass? broadcast;
  String? source;
  int? averageDurationPerEps;
  String? rating;
  List<AnimeStudioClass> studios;
  List<AnimeImageClass> pictures;
  String? background;
  List<CharacterDataClass> characters;
  List<RelatedAnimeClass> relatedAnimes;
  List<RelatedMangaClass> relatedMangas;
  List<RecommendedAnimeClass> recommendations;
  AnimeStatisticsClass statistics;

  AnimeDataClass(
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
    this.totalEpisodes,
    this.startSeason,
    this.broadcast,
    this.source,
    this.averageDurationPerEps,
    this.rating,
    this.studios,
    this.pictures,
    this.background,
    this.characters,
    this.relatedAnimes,
    this.relatedMangas,
    this.recommendations,
    this.statistics
  );

  AnimeDataClass fromMapUpdateAll(Map map){
    return AnimeDataClass(
      map['id'], 
      map['title'],
      map['main_picture'] != null ? 
        AnimeImageClass(map['main_picture']['medium'], map['main_picture']['large'])
      : null,
      map['alternative_titles'] != null ?
        AnimeAlternativeTitlesClass(
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
      : List.generate(map['genres'].length, (i) => AnimeGenreClass(
        map['genres'][i]['id'], map['genres'][i]['name']
      )), 
      map['created_at'], 
      map['updated_at'], 
      map['media_type'], 
      map['status'], 
      map['my_list_status'] != null ? 
        AnimeMyListStatusClass(
          map['my_list_status']['status'], 
          map['my_list_status']['score'],
          map['my_list_status']['num_episodes_watched'], 
          map['my_list_status']['is_rewatching'], 
          map['my_list_status']['start_date'], 
          map['my_list_status']['finish_date'], 
          map['my_list_status']['tags'],
          map['my_list_status']['updated_at']
        )
      : null, 
      map['num_episodes'], 
      map['start_season'] != null ?
        AnimeStartSeasonClass(
          map['start_season']['year'], 
          map['start_season']['season']
        )
      : null,
      map['broadcast'] != null ?
        AnimeBroadcastClass(
          map['broadcast']['day_of_the_week'], 
          map['broadcast']['start_time']
        )
      : null,
      map['source'], 
      map['average_episode_duration'], 
      map['rating'], 
      List.generate(map['studios'].length, (i) => AnimeStudioClass(
        map['studios'][i]['id'],
        map['studios'][i]['name']
      )), 
      map['pictures'] == null ? pictures :
      List.generate(map['pictures'].length, (i) => AnimeImageClass(
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
      List.generate(map['recommendations'].length, (i) => RecommendedAnimeClass(
        map['recommendations'][i]['node']['id'], 
        map['recommendations'][i]['node']['title'], 
        AnimeImageClass(
          map['recommendations'][i]['node']['main_picture']['medium'], 
          map['recommendations'][i]['node']['main_picture']['large']
        ),
        map['recommendations'][i]['num_recommendations']
      )), 
      map['statistics'] == null ? statistics :
      AnimeStatisticsClass(
        map['statistics']['status']['watching'] is String ? int.parse(map['statistics']['status']['watching']) : map['statistics']['status']['watching'], 
        map['statistics']['status']['completed'] is String ? int.parse(map['statistics']['status']['completed']) : map['statistics']['status']['completed'], 
        map['statistics']['status']['on_hold'] is String ? int.parse(map['statistics']['status']['on_hold']) : map['statistics']['status']['on_hold'], 
        map['statistics']['status']['dropped'] is String ? int.parse(map['statistics']['status']['dropped']) : map['statistics']['status']['dropped'], 
        map['statistics']['status']['plan_to_watch'] is String ? int.parse(map['statistics']['status']['plan_to_watch']) : map['statistics']['status']['plan_to_watch']
      )  
    );
  }

  factory AnimeDataClass.fetchNewInstance(int id){
    return AnimeDataClass(
      id, '', AnimeImageClass('', ''), AnimeAlternativeTitlesClass([], '', ''),
      null, null, null, null, null, null, 0, 0, null, [], '', '', '', '', 
      AnimeMyListStatusClass('', 0, 0, false, '', '', [], ''),
      0, null, null, null, null, null, [], [], null, [], [], [], [],
      AnimeStatisticsClass(0, 0, 0, 0, 0),
    );
  }

  factory AnimeDataClass.generateNewCopy(AnimeDataClass animeData){
    return AnimeDataClass(
      animeData.id, 
      animeData.title, 
      animeData.cover,
      animeData.alternativeTitles,
      animeData.startDate,
      animeData.endDate,
      animeData.synopsis,
      animeData.mean,
      animeData.rank,
      animeData.popularity,
      animeData.listedCount,
      animeData.scoredCount,
      animeData.nsfw,
      animeData.genres,
      animeData.creationTime,
      animeData.updatedTime,
      animeData.mediaType,
      animeData.status,
      animeData.myListStatus,
      animeData.totalEpisodes,
      animeData.startSeason,
      animeData.broadcast,
      animeData.source,
      animeData.averageDurationPerEps,
      animeData.rating,
      animeData.studios,
      animeData.pictures,
      animeData.background,
      animeData.characters,
      animeData.relatedAnimes,
      animeData.relatedMangas,
      animeData.recommendations,
      animeData.statistics
    );
  }
}