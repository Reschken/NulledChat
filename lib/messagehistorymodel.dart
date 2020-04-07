class MessageHistoryModel {
  Channel channel;
  Data data;

  MessageHistoryModel({this.channel, this.data});

  MessageHistoryModel.fromJson(Map<String, dynamic> json) {
    channel =
    json['channel'] != null ? new Channel.fromJson(json['channel']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.channel != null) {
      data['channel'] = this.channel.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Channel {
  String name;

  Channel({this.name});

  Channel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

class Data {
  List<Messages> messages;

  Data({this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = new List<Messages>();
      json['messages'].forEach((v) {
        messages.add(new Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.messages != null) {
      data['messages'] = this.messages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String id;
  String styled;
  String text;
  String createdAt;
  String channelName;
  User user;

  Messages(
      {this.id,
        this.styled,
        this.text,
        this.createdAt,
        this.channelName,
        this.user});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    styled = json['styled'];
    text = json['text'];
    createdAt = json['createdAt'];
    channelName = json['channelName'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['styled'] = this.styled;
    data['text'] = this.text;
    data['createdAt'] = this.createdAt;
    data['channelName'] = this.channelName;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  int id;
  String styled;
  String username;
  String discord;
  int shouts;

  User({this.id, this.styled, this.username, this.discord, this.shouts});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    styled = json['styled'];
    username = json['username'];
    discord = json['discord'];
    shouts = json['shouts'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['styled'] = this.styled;
    data['username'] = this.username;
    data['discord'] = this.discord;
    data['shouts'] = this.shouts;
    return data;
  }
}