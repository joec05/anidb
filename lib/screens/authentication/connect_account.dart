import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ConnectAccountPage extends StatefulWidget {
  final String url;
  final String codeVerifier;

  const ConnectAccountPage({
    super.key, 
    required this.url,
    required this.codeVerifier
  });

  @override
  _ConnectAccountPageState createState() => _ConnectAccountPageState();
}

class _ConnectAccountPageState extends State<ConnectAccountPage> {
  final ValueNotifier<double> _progress = ValueNotifier(0);

  @override
  void initState(){
    super.initState();
  }
  
  @override
  void dispose(){
    super.dispose();
    _progress.dispose();
  }

  void getAccessToken(String authCode) async{
    try{
      String uri = 'https://myanimelist.net/v1/oauth2/token';
      var res = await dio.post(
        uri,
        data: {
          'client_id': clientID,
          'code': authCode,
          'code_verifier': widget.codeVerifier,
          'grant_type': 'authorization_code',
        },
        options: Options(
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
        )
      );
      appStateClass.userTokenData = UserTokenClass.fromMapUpdate(res.data);
      appStateClass.appStorage.updateUserToken();
      runDelay(() => Navigator.pushAndRemoveUntil(
        context,
        NavigationTransition(
          page: const MainPageWidget()
        ),
        (Route<dynamic> route) => false
      ), navigatorDelayTime);
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            onLoadStop: (controller, uri){
              if(uri == null){return;}
              if(uri.toString().contains('code=') && uri.toString().contains(redirectUrl)){
                getAccessToken(uri.toString().split('code=')[1].split('&state=')[0]);
              }
            },
            onProgressChanged: (controller, progress) {
              if(mounted){
                _progress.value = progress / 100;
              }
            },
          ),
        ]
      )
    );
  }
}