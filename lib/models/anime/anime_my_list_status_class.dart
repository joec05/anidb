import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeMyListStatusClass {
  String? status;
  int score;
  int episodesWatched;
  bool isRewatching;
  String? startDate;
  String? finishDate;
  List<String>? tags;
  String updatedTime;
  
  AnimeMyListStatusClass(
    this.status,
    this.score,
    this.episodesWatched,
    this.isRewatching,
    this.startDate,
    this.finishDate,
    this.tags,
    this.updatedTime
  );

  factory AnimeMyListStatusClass.fromMap(Map map){
    return AnimeMyListStatusClass(
      map['status'], 
      map['score'],
      map['num_episodes_watched'], 
      map['is_rewatching'], 
      map['start_date'], 
      map['finish_date'], 
      map['tags'], 
      map['updated_at']
    );
  }

  factory AnimeMyListStatusClass.generateNewInstance(){
    return AnimeMyListStatusClass(
      null, 0, 0, false, '', '', [], ''
    );
  }

  factory AnimeMyListStatusClass.generateNewCopy(AnimeMyListStatusClass? myListStatus){
    if(myListStatus == null){
      return AnimeMyListStatusClass.generateNewInstance();
    }
    return AnimeMyListStatusClass(
      myListStatus.status, 
      myListStatus.score, 
      myListStatus.episodesWatched, 
      myListStatus.isRewatching, 
      myListStatus.startDate, 
      myListStatus.finishDate, 
      myListStatus.tags, 
      myListStatus.updatedTime
    );
  }
}

class AnimeStatusNotifier extends Notifier<AnimeMyListStatusClass> {
  @override
  AnimeMyListStatusClass build() {
    return AnimeMyListStatusClass.generateNewInstance();
  }

  void update(AnimeMyListStatusClass updatedAnimeListStatus) {
    state = updatedAnimeListStatus;
  }

  AnimeMyListStatusClass getState() => state;
}