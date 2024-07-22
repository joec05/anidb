import 'package:anidb/global_files.dart';

class UserAnimeListStatusClass{
  List<AnimeDataClass> animeList;
  String status;
  bool canPaginate;
  PaginationStatus paginationStatus;

  UserAnimeListStatusClass(
    this.animeList,
    this.status,
    this.canPaginate,
    this.paginationStatus
  );

  UserAnimeListStatusClass copy() {
    return UserAnimeListStatusClass(
      animeList,
      status,
      canPaginate,
      paginationStatus
    );
  }

  UserAnimeListStatusClass updatePaginationStatus(PaginationStatus paginationStatus) {
    return UserAnimeListStatusClass(
      animeList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }

  UserAnimeListStatusClass updateCanPaginate(bool canPaginate) {
    return UserAnimeListStatusClass(
      animeList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }
}