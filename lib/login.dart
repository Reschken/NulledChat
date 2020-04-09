import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class Login extends StatelessWidget{
  @override
  Widget build (BuildContext context){
     return WebviewScaffold(
              url:
                  "https://www.nulled.to/index.php?app=core&module=global&section=login",
              appBar: new AppBar(
                title: new Text("Login"),
              ),
            );
  }
}