import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:anime_list_app/global_files.dart';
import 'package:anime_list_app/streams/has_authenticated_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final talker = Talker();

Future<void> main() async {
  talker.debug('Starting AniDB...');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  ByteData data = await PlatformAssetBundle().load('assets/certificate/ca.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  tz.initializeTimeZones();
  await sharedPreferencesController.initialize();
  apiCallRepo.initialize();
  themeModel.mode.value = await sharedPreferencesController.getThemeModeData();
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () {
      FlutterNativeSplash.remove();
      runApp(ProviderScope(
        observers: [
          TalkerRiverpodObserver(talker: talker)
        ],
        child: const MyApp(),
      ));
    }
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  AssetImage assetImage = const AssetImage('assets/images/icon.png');
  late StreamSubscription _updateHasAuthenticated;
  late AutoDisposeAsyncNotifierProvider<HasAuthenticatedNotifier, void> hasAuthenticatedNotifier;

  @override void initState(){
    super.initState();
    initializeApp();
    hasAuthenticatedNotifier = AsyncNotifierProvider.autoDispose<HasAuthenticatedNotifier, void>(
      () => HasAuthenticatedNotifier()
    );
    _updateHasAuthenticated = HasAuthenticatedStreamClass().hasAuthenticatedStream.listen((HasAuthenticatedClass data) {
      if(mounted){
        context.read(hasAuthenticatedNotifier.notifier).authenticate(
          context,
          data.url,
          data.codeVerifier
        );
      }
    });
  }

  @override void dispose(){
    super.dispose();
    _updateHasAuthenticated.cancel();
  }

  Future<void> initializeApp() async{
    Map userTokenMap = await secureStorageController.fetchUserToken();
    if(userTokenMap['token_type'].isEmpty){
      //callLogin();
    }else{
      authRepo.userTokenData = UserTokenClass.fromMapRetrieve(userTokenMap);
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
    await context.pushNamed('connect-account', pathParameters: {
      'url': 'https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=$clientID&code_challenge=$codeVerifier&state=RequestIDABC',
      'codeVerifier': codeVerifier
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(assetImage, context);
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: defaultAppBarDecoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: getScreenWidth() * 0.3,
                height: getScreenWidth() * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/icon.png'))
                )
              ),
              SizedBox(
                height: getScreenHeight() * 0.02
              ),
              const Text('AniDB', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19
              )),
              SizedBox(
                height: getScreenHeight() * 0.035
              ),
              Builder(
                builder: (_) {  
                  AsyncValue<void> viewHasAuthenticatedState = ref.watch(hasAuthenticatedNotifier);
                  return viewHasAuthenticatedState.when(
                    data: (data) => ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(
                          getScreenWidth() * 0.45,
                          getScreenHeight() * 0.07
                        ))
                      ),
                      onPressed: callLogin,
                      child: const Text('Sign in with MAL')
                    ),
                    loading: () => ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(
                          getScreenWidth() * 0.45,
                          getScreenHeight() * 0.07
                        ))
                      ),
                      onPressed: null,
                      child: const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator()
                      )
                    ),
                    error: (obj, stackTrace) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          handler.displaySnackbar(
                            context,
                            SnackbarType.error, 
                            obj.toString()
                          );
                        }
                      });
      
                      return ElevatedButton(
                        style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(Size(
                            getScreenWidth() * 0.45,
                            getScreenHeight() * 0.07
                          ))
                        ),
                        onPressed: callLogin,
                        child: const Text('Sign in with MAL')
                      );
                    }
                  );
                }
              )
            ]
          )
        ),
      )
    );
  }
}

class HasAuthenticatedNotifier extends AutoDisposeAsyncNotifier<void>{
  HasAuthenticatedNotifier();

  @override
  FutureOr<void> build() async {
    return;
  }

  Future<void> authenticate(
    BuildContext context, 
    String authCode,
    String codeVerifier
  ) async {
    state = const AsyncLoading();
    APIResponseModel response = await authRepo.getAccessToken(context, authCode, codeVerifier);
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      state = const AsyncData(null);
    }
  }
}