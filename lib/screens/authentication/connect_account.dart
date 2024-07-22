import 'package:anidb_app/global_files.dart';
import 'package:anidb_app/streams/has_authenticated_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

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
              shouldOverrideUrlLoading: (controller, uri) async {
                if(uri.toString().contains('code=') && uri.toString().contains(redirectUrl)){
                  context.pop();
                  HasAuthenticatedStreamClass().emitData(
                    HasAuthenticatedClass(
                      uri.toString().split('code=')[1].split('&state=')[0], widget.codeVerifier
                    )
                  );
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ]
        ),
      )
    );
  }
}