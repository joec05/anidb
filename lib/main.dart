import 'dart:async';
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
      title: 'AniDB',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
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
    precacheImage(assetImage, context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: defaultAppBarDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: assetImage,
              width: getScreenWidth() * 0.4, 
              height: getScreenWidth() * 0.4
            ),
          ],
        )
      )
    );
  }
}