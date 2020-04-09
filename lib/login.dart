import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'main.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flutterwebview = FlutterWebviewPlugin();
    void _isLogged() {
      final Future = flutterwebview.evalJavascript("ipb.vars.session_id");
      Future.then((String data) {
        var token = data.substring(1, data.length - 1);
        Navigator.pop(context, token);
      });
    }
    flutterwebview.onStateChanged.listen((data) => {
          if (data.url.toString() == "https://www.nulled.to/") {_isLogged()}
        });
    return WebviewScaffold(
      url:
          "https://www.nulled.to/index.php?app=core&module=global&section=login",
      appBar: new AppBar(
        title: new Text("Login"),
      ),
    );
  }
}
