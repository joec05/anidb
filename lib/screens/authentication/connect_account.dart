import 'package:anime_list_app/global_files.dart';
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
  ConnectAccountPageState createState() => ConnectAccountPageState();
}

class ConnectAccountPageState extends State<ConnectAccountPage> {

  @override
  void initState(){
    super.initState();
  }
  
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
              onLoadStop: (controller, uri){
                if(uri == null){return;}
                if(uri.toString().contains('code=') && uri.toString().contains(redirectUrl)){
                  authRepo.getAccessToken(
                    context,
                    uri.toString().split('code=')[1].split('&state=')[0],
                    widget.codeVerifier
                  );
                }
              },
            ),
          ]
        ),
      )
    );
  }
}