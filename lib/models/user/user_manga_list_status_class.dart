import 'package:anime_list_app/global_files.dart';

class UserMangaListStatusClass{
  List<int> mangasList;
  String status;
  bool canPaginate;
  PaginationStatus paginationStatus;

  UserMangaListStatusClass(
    this.mangasList,
    this.status,
    this.canPaginate,
    this.paginationStatus
  );
}