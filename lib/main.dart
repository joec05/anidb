import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  ByteData data = await PlatformAssetBundle().load('assets/certificate/ca.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  tz.initializeTimeZones();
  await sharedPreferencesController.initialize();
  themeModel.mode.value = await sharedPreferencesController.getThemeModeData();
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const ProviderScope(
      child: MyApp(),
    ))
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
      routes: [
        GoRoute(
          name: 'connect-account',
          path: 'connect-account/:url/:codeVerifier',
          builder: (context, state) => ConnectAccountPage(url: state.pathParameters['url']!, codeVerifier: state.pathParameters['codeVerifier']!)
        ),
        GoRoute(
          name: 'main-page',
          path: 'main-page',
          builder: (context, state) => const MainPage()
        ),
        GoRoute(
          name: 'settings-page',
          path: 'settings-page',
          builder: (context, state) => const SettingsPage()
        ),
        GoRoute(
          name: 'search-page',
          path: 'search-page',
          builder: (context, state) => const SearchPage()
        ),
        GoRoute(
          name: 'view-user-statistics',
          path: 'view-user-statistics',
          builder: (context, state) => const ViewUserStatistics()
        ),
        GoRoute(
          name: 'view-user-anime-lists',
          path: 'view-user-anime-lists',
          builder: (context, state) => const ViewUserAnimeLists()
        ),
        GoRoute(
          name: 'view-user-manga-lists',
          path: 'view-user-manga-lists',
          builder: (context, state) => const ViewUserMangaLists()
        ),
        GoRoute(
          name: 'view-more-anime',
          path: 'view-more-anime/:label',
          builder: (context, state) => ViewMoreAnime(label: state.pathParameters['label']!, displayType: state.extra as AnimeBasicDisplayType)
        ),
        GoRoute(
          name: 'view-more-manga',
          path: 'view-more-manga/:label',
          builder: (context, state) => ViewMoreManga(label: state.pathParameters['label']!, displayType: state.extra as MangaBasicDisplayType )
        ),
        GoRoute(
          name: 'view-more-characters',
          path: 'view-more-characters/:label',
          builder: (context, state) => ViewMoreCharacters(label: state.pathParameters['label']!, displayType: state.extra as CharacterBasicDisplayType )
        ),
        GoRoute(
          name: 'view-anime-details',
          path: 'view-anime-details/:animeID',
          builder: (context, state) => ViewAnimeDetails(animeID: int.parse(state.pathParameters['animeID']!))
        ),
        GoRoute(
          name: 'view-manga-details',
          path: 'view-manga-details/:mangaID',
          builder: (context, state) => ViewMangaDetails(mangaID: int.parse(state.pathParameters['mangaID']!))
        ),
        GoRoute(
          name: 'view-character-details',
          path: 'view-character-details/:characterID',
          builder: (context, state) => ViewCharacterDetails(characterID: int.parse(state.pathParameters['characterID']!))
        ),
        GoRoute(
          name: 'view-picture',
          path: 'view-picture',
          builder: (context, state) => ViewPicturePage(imageData: state.extra)
        )
      ]
    )
  ]
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeModel.mode,
      builder: (context, mode, child) => MaterialApp.router(
        title: 'AniDB',
        theme: globalTheme.light,
        darkTheme: globalTheme.dark,
        themeMode: mode,
        routerConfig: _router
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AssetImage assetImage = const AssetImage('assets/images/icon.png');

  @override void initState(){
    super.initState();
    Timer(const Duration(milliseconds: 1500), (){
      initializeApp();
    });  
  }

  @override void dispose(){
    super.dispose();
  }

  void initializeApp() async{
    Map userTokenMap = await secureStorageController.fetchUserToken();
    if(userTokenMap['token_type'].isEmpty){
      callLogin();
      FlutterNativeSplash.remove();
    }else{
      authRepo.userTokenData = UserTokenClass.fromMapRetrieve(userTokenMap);
      FlutterNativeSplash.remove();
      if(mounted) {
        context.pushReplacement('/main-page');
      }
    }
  }

  void callLogin() async{
    String codeVerifier = '';
    String alphabets = 'abcdefghijklmnopqrstuvwxyz';
    List<String> allowedChars = [];
    allowedChars.addAll(alphabets.split(''));
    allowedChars.addAll(alphabets.toUpperCase().split(''));
    allowedChars.addAll(["-", ".", "_", "~", ...'0123456789'.split('')]);
    while(codeVerifier.length < 128){
      codeVerifier = '$codeVerifier${allowedChars[Random().nextInt(allowedChars.length)]}';
    }
    while(context.canPop()) {
      context.pop();
    }
    var hasSignedIn = await context.pushNamed('connect-account', pathParameters: {
      'url': 'https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=$clientID&code_challenge=$codeVerifier&state=RequestIDABC',
      'codeVerifier': codeVerifier
    });
    if(hasSignedIn == true) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(assetImage, context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: defaultAppBarDecoration
      )
    );
  }
}