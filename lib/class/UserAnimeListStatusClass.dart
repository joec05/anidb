import 'package:anime_list_app/appdata/GlobalEnums.dart';

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
}