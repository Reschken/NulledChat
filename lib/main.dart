import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nulled/emojimodel.dart';
import 'messagemodel.dart';
import 'selfUsermodel.dart';
import 'messagehistorymodel.dart';
import 'deletedmodel.dart';
import 'package:html/parser.dart';
import 'package:extended_text/extended_text.dart';

void main() {
  runApp(new MaterialApp(
    home: new MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _scrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ChatMessage {
  String username, txt, styled, id;
  int group;
  bool isDeleted;

  ChatMessage({
    this.username,
    this.txt,
    this.group,
    this.id,
    this.isDeleted,
    this.styled,
  });
}

class Emoji {
  String file, typed;

  Emoji({this.file, this.typed});
}

class Group {
  String name;
  int id;
  Color color;

  Group({this.name, this.id, this.color});
}

class SelfUser {
  String username;
  int group;

  SelfUser({this.username, this.group});
}

// TODO Add loading functions
class _State extends State<MainApp> {
  SocketIOManager socketManager;
  TextEditingController messageInput;
  ScrollController _scrollController;
  SocketIO socket;
  bool _isProbablyConnected = false;
  List<ChatMessage> messagesList = new List<ChatMessage>();
  List<Group> groupsList = new List<Group>();
  List<Emoji> emojisList = new List<Emoji>();
  SelfUser selfUser;
  String token = "74e2eca66449d3ac6519f6ba05cd49df";
  bool isAuthenticated = false;

  @override
  void initState() {
    socketManager = new SocketIOManager();
    messageInput = new TextEditingController();
    _scrollController = ScrollController();
    initGroups();
    super.initState();
    initSocket();
  }

  initGroups() {
    groupsList.add(new Group(name: "Aqua", id: 91, color: Colors.indigo));
    groupsList.add(new Group(name: "Aqua", id: 90, color: Colors.lightGreen));
    groupsList.add(new Group(name: "Mod", id: 9, color: Colors.teal));
    groupsList
        .add(new Group(name: "Legendary", id: 38, color: Colors.amberAccent));
    groupsList
        .add(new Group(name: "Royal", id: 12, color: Colors.lightBlueAccent));
    groupsList.add(new Group(name: "Nova", id: 92, color: Colors.deepOrange));
    groupsList.add(new Group(name: "User", id: 3, color: Colors.grey));
    // TODO Add Rainbow effect
    groupsList
        .add(new Group(name: "Heavenly", id: 104, color: Colors.purpleAccent));
    groupsList.add(new Group(name: "Vip", id: 7, color: Colors.pinkAccent));
  }

  // TODO Add Delete
  initSocket() async {
    setState(() => _isProbablyConnected = true);
    SocketIO tempSocket = await socketManager.createInstance(SocketOptions(
        "https://chat-ssl.nulled.to:443/",
        enableLogging: false,
        transports: [Transports.WEB_SOCKET]));

    // Event Listeners
    tempSocket.onConnect((data) {
      print("Connected");
      _getConnection(data);
    });
    tempSocket.onConnectError(print);
    tempSocket.onConnectTimeout(print);
    tempSocket.onError(print);
    tempSocket.onDisconnect(print);
    tempSocket.on("message", (data) {
      _getMessage(data);
    });
    tempSocket.on("authenticated", (data) {
      print("Authenticated");
      _getAuthenticated(data);
    });
    tempSocket.on("subscribed", (data) {
      print("Subscribed");
      _getSubscribed(data);
    });
    tempSocket.on("deleted", (data) {
      print("Deleted");
      _getDeleted(data);
    });
    tempSocket.on("emojis", (data) {
      print("Emojis");
      _getEmoji(data);
    });
    tempSocket.connect();
    socket = tempSocket;
  }

  _getConnection(dynamic data) {
    print("Subscribing to general");
    socket.emit("emojis", [
      {"all": "all"}
    ]);
  }

  _getDeleted(dynamic data) {
    DeletedModel deleted = DeletedModel.fromJson(data);
    int index = messagesList.indexWhere((msg) => msg.id == deleted.id);
    setState(() {
      messagesList[index].isDeleted = true;
    });
  }

  // On Subscribed
  _getSubscribed(dynamic data) {
    MessageHistoryModel history = MessageHistoryModel.fromJson(data);
    for (int i = 24; i >= 0; i--) {
      setState(() {
        messagesList.add(new ChatMessage(
            username: history.data.messages[i].user.username,
            txt: history.data.messages[i].text,
            group: 3,
            id: history.data.messages[i].id,
            isDeleted: false,
            styled: history.data.messages[i].styled));
      });
    }
  }

  // On Authenticated
  _getAuthenticated(dynamic data) {
    SelfuserModel user = SelfuserModel.fromJson(data);
    setState(() {
      selfUser = new SelfUser(
          username: user.data.user.username, group: user.data.user.group);
      isAuthenticated = true;
    });
  }

  _getEmoji(dynamic data) {
    EmojiModel model = EmojiModel.fromJson(data);
    for (int i = 0; i < model.emojis.length; i++) {
      emojisList.add(
          new Emoji(file: model.emojis[i].image, typed: model.emojis[i].typed));
    }
    socket.emit("subscribe", [
      {"channelName": "general"}
    ]);
  }

  _getMessage(dynamic data) {
    MessageModel message = MessageModel.fromJson(data);
    String txt = message.data.message.text;
    String username = message.data.message.user.username;
    String styled = message.data.message.styled;
    int group = message.data.message.user.group;
    String id = message.data.message.id;

    ChatMessage newmsg = new ChatMessage(
        txt: txt,
        username: username,
        group: group,
        id: id,
        isDeleted: false,
        styled: styled);
    setState(() {
      messagesList.add(newmsg);
    });
    _getContent(newmsg);
    _scrollController.animateTo(_scrollController.position.maxScrollExtent + 70,
        duration: Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  _sendMessage() async {
    if (socket != null) {
      if (isAuthenticated) {
        socket.emit("message", [
          {"channelName": "general", "text": messageInput.text}
        ]);
        messageInput.clear();
        print('Message sent');
      }
    }
  }

  _mentionUser(String user) {
    print(user);
    messageInput.text += "@" + user;
    messageInput.selection = TextSelection.fromPosition(
        TextPosition(offset: messageInput.text.length));
  }

  void _login() async {
    String url =
        'https://www.nulled.to/index.php?app=core&module=global&section=login';
    final flutterwebview = FlutterWebviewPlugin();

    void _loaded() {
      final Future = flutterwebview.evalJavascript("ipb.vars.session_id");
      Future.then((String data) {
        socket.emit("authenticate", [
          {
            "token":
                "0ac4533d6bb868eec16981ec2512104a" /*data.substring(1, data.length - 1)*/
          }
        ]);
      });
      flutterwebview.dispose();
      flutterwebview.close();
    }

    await flutterwebview.launch(url, hidden: true);
    flutterwebview.onStateChanged.listen((data) => {
          if (data.type == WebViewState.finishLoad) {_loaded()}
        });
  }

  List<InlineSpan> messageContent = [];
  List<Emoji> emojisInMsg;
  _getContent(ChatMessage message) {
    messageContent.clear();
    if (message.styled != null) {
      if (message.styled.contains("style_emoticons")) {
        RegExp image = new RegExp(                                                  
            r"(?<=https:\/\/static.nulled.to\/public\/style_emoticons\/default\/).+?(?=')");

        var matches = image.allMatches(message.styled);
        var typed;

        emojisInMsg = new List<Emoji>();
        // For every match (emoji)
        for (int i = 0; i < matches.length; i++) {
          // For every Emoji in Emoji List
          for (int j = 0; j < emojisList.length; j++) {
            // Check if current Emoji is the one that matched
            if (emojisList[j].file.toLowerCase() == matches.elementAt(i).group(0).toLowerCase()) {
              typed = emojisList[j].typed;
            }
          }
          // Add current Emoji to list with Emojis in this message
          emojisInMsg.add(
              new Emoji(typed: typed, file: matches.elementAt(i).group(0)));
        }
        // For every Emoji in Message
        for (int i = 0; i < emojisInMsg.length; i++) {
          Emoji e = emojisInMsg[i];
          var chunks = message.txt.split(e.typed);
          var image = 'lib/assets/emojis/' + e.file;
          if(chunks.length == 1){
            print("needed to be modded");
            chunks.add(" ");
          } else {
            print("you good");
          }

          messageContent.add(TextSpan(text: chunks[0]));
          messageContent.add(
              ImageSpan(AssetImage(image), imageHeight: 30, imageWidth: 30));
          messageContent.add(TextSpan(text: chunks[1]));

          return messageContent;
        }
      } else {
        messageContent.add(TextSpan(text: message.txt));
        return messageContent;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: new Text('Nulled.to Chat'),
      ),
      body: ScrollConfiguration(
          behavior: _scrollBehavior(),
          child: new SingleChildScrollView(
            controller: _scrollController,
            padding: new EdgeInsets.all(16.0),
            child: new Container(
              child: new Column(
                children: <Widget>[
                  new ListView.builder(
                    controller: ScrollController(),
                    itemCount: messagesList.length,
                    shrinkWrap: true,
                    reverse: false,
                    itemBuilder: ((ctx, idx) {
                      return _msgContainer(messagesList[idx]);
                    }),
                  )
                ],
              ),
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                flex: 5,
                child: new Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 5.0,
                      right: 5.0,
                      top: 5.0),
                  child: new TextField(
                    controller: messageInput,
                    decoration: new InputDecoration.collapsed(
                        hintText: 'Send a message'),
                  ),
                )),
            Expanded(
                flex: 1,
                child: new Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: .5,
                      right: .5,
                      top: .5),
                  child: new FlatButton.icon(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send),
                      label: new Text('')),
                ))
          ],
        ),
        elevation: 9.0,
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        notchMargin: 8.0,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
            child: isAuthenticated ? Text(selfUser.username) : Text(""),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text("Login"),
            onTap: () {
              _login();
            },
          )
        ]),
      ),
    );
  }

  // Message Container
  Widget _msgContainer(ChatMessage message) {
    // Checking for Group and assign color
    Color groupColor = Colors.grey;
    for (var i = 0; i < groupsList.length; i++) {
      if (groupsList[i].id == message.group) {
        groupColor = groupsList[i].color;
      }
    }

    if (selfUser == null) {
      // Message from someone
      return new GestureDetector(
        onDoubleTap: () {
          _mentionUser(message.username);
        },
        child: Container(
          decoration: new BoxDecoration(
              color: message.isDeleted ? Colors.red[400] : Colors.white,
              border: new Border.all(color: groupColor),
              borderRadius: new BorderRadius.circular(10.0)),
          margin: new EdgeInsets.all(3.0),
          padding: new EdgeInsets.only(
              top: 16.0, bottom: 16.0, right: 8.0, left: 8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Text(
                message.username,
                style: new TextStyle(
                    color: message.isDeleted ? Colors.white : groupColor),
              ),
              new Container(
                child:
                    ExtendedText.rich(TextSpan(children: _getContent(message))),
              )
            ],
          ),
        ),
      );
    } else {
      if (message.username == selfUser.username) {
        // Message from you
        return new GestureDetector(
          child: Container(
            decoration: new BoxDecoration(
                color: message.isDeleted ? Colors.red[400] : Colors.white,
                border: new Border.all(color: groupColor),
                borderRadius: new BorderRadius.circular(10.0)),
            margin: new EdgeInsets.all(3.0),
            padding: new EdgeInsets.only(
                top: 16.0, bottom: 16.0, right: 8.0, left: 8.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text(
                  message.username,
                  style: new TextStyle(
                      color: message.isDeleted ? Colors.white : groupColor,
                      fontWeight: FontWeight.bold),
                ),
                new Text(
                  message.txt,
                )
              ],
            ),
          ),
        );
      }
    }
  }
}
