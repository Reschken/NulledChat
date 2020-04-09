import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nulled/emojimodel.dart';
import 'messagemodel.dart';
import 'selfUsermodel.dart';
import 'messagehistorymodel.dart';
import 'deletedmodel.dart';
import 'package:photo_view/photo_view.dart';
import 'package:extended_text/extended_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'login.dart';

void main() {
  runApp(new MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.pink,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
    ),
    home:
        MainApp(), /*,
      routes: {'/': (context) => MainApp(), '/login': (context) => Login()}*/
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

class MSGChunk {
  String before, image, behind;

  MSGChunk({this.before, this.image, this.behind});
}

class ChatMessageContent {
  TextSpan before, behind;
  ImageSpan image;

  ChatMessageContent({this.before, this.behind, this.image});
}

// TODO Add loading functions
class _State extends State<MainApp> {
  SocketIOManager socketManager;
  TextEditingController messageInput;
  ScrollController _scrollController;
  SocketIO socket;
  bool _isProbablyConnected = false;
  List<ChatMessage> messagesList = new List<ChatMessage>();
  List<ChatMessageContent> contentsList = new List<ChatMessageContent>();
  List<Group> groupsList = new List<Group>();
  List<Emoji> emojisList = new List<Emoji>();
  List<MSGChunk> chunks = new List<MSGChunk>();
  SelfUser selfUser;
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
    groupsList.add(new Group(name: "Moderator", id: 6, color: Colors.teal));
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
    _tryAuthenticate();
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

  _setAuthenticate(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(token, token);
    _tryAuthenticate();
  }

  _tryAuthenticate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? 0;
    socket.emit("authenticate", [
      {"token": token}
    ]);
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
    String username;
    int group;
    String styled;
    String id;
    bool isChatMessage;
    if (message.data.message.user != null) {
      username = message.data.message.user.username;
      group = message.data.message.user.group;
      id = message.data.message.id;
      styled = message.data.message.styled;
      isChatMessage = true;
    } else {
      isChatMessage = false;
    }

    if (isChatMessage) {
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
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut);
    } else {
      print("Got non-user message.");
    }
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

  List<Emoji> emojisInMsg;

  _getContent(ChatMessage message) {
    chunks.clear();
    if (message.styled != null) {
      if (message.styled.contains("style_emoticons")) {
        RegExp image = new RegExp(
            r"(?<=https:\/\/static.nulled.to\/public\/style_emoticons\/default\/).+?(?=')");

        var matches = image.allMatches(message.styled);
        var typed;

        // Good working Message to Emoji List Method :)
        emojisInMsg = new List<Emoji>();
        // For every match (emoji)
        for (int i = 0; i < matches.length; i++) {
          // For every Emoji in Emoji List
          for (int j = 0; j < emojisList.length; j++) {
            // Check if current Emoji is the one that matched
            if (emojisList[j].file == matches.elementAt(i).group(0)) {
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
          var chunk = message.txt.toLowerCase().split(e.typed.toLowerCase());
          var image = 'lib/assets/emojis/' + e.file;

          String before;
          String middle = image;
          String behind;
          if (message.txt.endsWith(e.typed.toLowerCase()) ||
              message.txt.endsWith(e.typed)) {
            before = chunk[0];
            behind = "";
          } else if (message.txt.startsWith(e.typed)) {
            before = "";
            behind = chunk[1];
          } else {
            before = chunk[0];
            behind = chunk[1];
          }
          chunks
              .add(new MSGChunk(before: before, image: middle, behind: behind));
        }
        for (int j = 0; j < chunks.length; j++) {
          String before = chunks[j].before;
          String image = chunks[j].image;
          String behind = chunks[j].behind;

          contentsList.add(new ChatMessageContent(
              before: TextSpan(text: before),
              behind: TextSpan(text: behind),
              image: ImageSpan(AssetImage(image),
                  imageHeight: 30, imageWidth: 30)));
        }
      } else {
        contentsList
            .add(new ChatMessageContent(before: TextSpan(text: message.txt)));
      }
    }
  }

  _getImageDialog(BuildContext context, ChatMessage message) {
    RegExp exp =
        new RegExp(r"(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+");
    var matches = exp.allMatches(message.txt);
    print(matches.elementAt(0).group(0).toString());
    if (matches.length != 0) {
      var url = matches.first.group(0).toString();
      var url_ext = url.split('.').last;
      bool isPic;
      List<String> url_exts = ["png", "jpg", "jpeg", "gif"];
      for (int i = 0; i < url_exts.length; i++) {
        if (url_exts[i] == url_ext) {
          isPic = true;
        }
      }
      if (isPic == true) {
        var image = matches.first.group(0).toString();
        print("Image found");
        print(image);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                child: PhotoView(
                  tightMode: true,
                  imageProvider: CachedNetworkImageProvider(url),
                  heroAttributes: const PhotoViewHeroAttributes(tag: "Image"),
                ),
              ),
            );
          },
        );
      } else {
        print(message.txt + " Contains url, but no image");
      }
    }
  }

  Brightness brightnessValue;
  @override
  Widget build(BuildContext context) {
    brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
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
        color: isDark ? Colors.black26 : Colors.white,
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
            onTap: () async {
              final result = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
              _setAuthenticate(result);
            },
          )
        ]),
      ),
    );
  }

  // Message Container
  Widget _msgContainer(ChatMessage message) {
    _getContent(message);
    bool isDark = brightnessValue == Brightness.dark;
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
        onTap: () {
          print("Click");
          _getImageDialog(context, message);
        },
        child: Container(
          decoration: new BoxDecoration(
              color: message.isDeleted
                  ? Colors.red[400]
                  : isDark ? Colors.black45 : Colors.white,
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
                padding: EdgeInsets.all(2.0),
                child: contentsList.last.image != null
                    ? ExtendedText.rich(TextSpan(children: <InlineSpan>[
                        contentsList.last.before,
                        contentsList.last.image,
                        contentsList.last.behind
                      ]))
                    : ExtendedText.rich(TextSpan(
                        children: <InlineSpan>[contentsList.last.before])),
              )
            ],
          ),
        ),
      );
    }
  }
}
