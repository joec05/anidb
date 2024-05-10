import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaMyListStatusClass{
  String? status;
  int score;
  int volumesRead;
  int chaptersRead;
  bool isRereading;
  String? startDate;
  String? finishDate;
  List<String>? tags;
  String updatedTime;

  MangaMyListStatusClass(
    this.status,
    this.score,
    this.volumesRead,
    this.chaptersRead,
    this.isRereading,
    this.startDate,
    this.finishDate,
    this.tags,
    this.updatedTime
  );

  factory MangaMyListStatusClass.generateNewInstance(){
    return MangaMyListStatusClass(
      '', 0, 0 , 0 , false , '', '', [], ''
    );
  }

  factory MangaMyListStatusClass.fromMap(Map map){
    return MangaMyListStatusClass(
      map['status'], 
      map['score'],
      map['num_volumes_read'], 
      map['num_chapters_read'], 
      map['is_rereading'], 
      map['start_date'], 
      map['finish_date'], 
      map['tags'], 
      map['updated_at']
    );
  }
  
  factory MangaMyListStatusClass.generateNewCopy(MangaMyListStatusClass? myListStatus){
    if(myListStatus == null){
      return MangaMyListStatusClass.generateNewInstance();
    }
    return MangaMyListStatusClass(
      myListStatus.status,
      myListStatus.score,
      myListStatus.volumesRead,
      myListStatus.chaptersRead,
      myListStatus.isRereading,
      myListStatus.startDate,
      myListStatus.finishDate,
      myListStatus.tags,
      myListStatus.updatedTime
    );
  }
}

class MangaStatusNotifier extends Notifier<MangaMyListStatusClass> {
  @override
  MangaMyListStatusClass build() {
    return MangaMyListStatusClass.generateNewInstance();
  }

  void update(MangaMyListStatusClass updatedMangaListStatus) {
    state = updatedMangaListStatus;
  }

  MangaMyListStatusClass getState() => state;
}