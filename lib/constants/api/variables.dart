import 'package:flutter_dotenv/flutter_dotenv.dart';

String redirectUrl = dotenv.env['REDIRECT_URL']!;

String malApiUrl = dotenv.env['MAL_BASE_URL']!;

String jikanApiUrl = dotenv.env['JIKAN_BASE_URL']!;

String fetchAllAnimeFieldsStr = dotenv.env['ANIME_FIELDS_FETCHED']!;

String fetchAllMangaFieldsStr = dotenv.env['MANGA_FIELDS_FETCHED']!;