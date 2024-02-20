import 'package:anime_list_app/global_files.dart';

class UserAnimeListStatusClass{
  List<int> animesList;
  String status;
  bool canPaginate;
  PaginationStatus paginationStatus;

  UserAnimeListStatusClass(
    this.animesList,
    this.status,
    this.canPaginate,
    this.paginationStatus
  );

  UserAnimeListStatusClass updatePaginationStatus(PaginationStatus paginationStatus) {
    return UserAnimeListStatusClass(
      animesList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }

  UserAnimeListStatusClass updateCanPaginate(bool canPaginate) {
    return UserAnimeListStatusClass(
      animesList, 
      status, 
      canPaginate, 
      paginationStatus
    );
  }
}