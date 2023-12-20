import 'dart:io';
import 'dart:math';
import 'package:anime_list_app/main_page.dart';
import 'package:anime_list_app/appdata/global_functions.dart';
import 'package:anime_list_app/appdata/global_variables.dart';
import 'package:anime_list_app/appdata/private_data.dart';
import 'package:anime_list_app/class/user_token_class.dart';
import 'package:anime_list_app/connect_account.dart';
import 'package:anime_list_app/state/main.dart';
import 'package:anime_list_app/styles/app_styles.dart';
import 'package:anime_list_app/transition/navigation_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await PlatformAssetBundle().load('assets/certificate/ca.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawk Anime List',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override void initState(){
    super.initState();
    initializeApp();
  }

  @override void dispose(){
    super.dispose();
  }

  void initializeApp() async{
    Future.delayed(const Duration(milliseconds: 3000), () async{
      Map userTokenMap = await appStateClass.appStorage.fetchUserToken();
      if(userTokenMap['token_type'].isEmpty){
        callLogin();
      }else{
        appStateClass.userTokenData = UserTokenClass.fromMapRetrieve(userTokenMap);
        runDelay(() => Navigator.pushAndRemoveUntil(
          context,
          NavigationTransition(
            page: const MainPageWidget()
          ),
          (Route<dynamic> route) => false
        ), navigatorDelayTime);
      }
    });
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
    runDelay(() async{
      Navigator.pushAndRemoveUntil(
        context,
        NavigationTransition(
          page: ConnectAccountPage(
            url: 'https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=$clientID&code_challenge=$codeVerifier&state=RequestIDABC',
            codeVerifier: codeVerifier
          )
        ),
        (Route<dynamic> route) => false
      );
    }, navigatorDelayTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: defaultAppBarDecoration,
        child: Center(
          child: Image.asset(iconImageUrl, width: getScreenWidth() * 0.3, height: getScreenWidth() * 0.3)
        )
      )
    );
  }
}
