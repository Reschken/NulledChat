class MessageModel {
  bool private;
  Channel channel;
  Data data;

  MessageModel({this.private, this.channel, this.data});

  MessageModel.fromJson(Map<String, dynamic> json) {
    private = json['private'];
    channel =
    json['channel'] != null ? new Channel.fromJson(json['channel']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['private'] = this.private;
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
  Message message;

  Data({this.message});

  Data.fromJson(Map<String, dynamic> json) {
    message =
    json['message'] != null ? new Message.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.message != null) {
      data['message'] = this.message.toJson();
    }
    return data;
  }
}

class Message {
  String createdAt;
  Channel channel;
  String text;
  User user;
  String styled;
  String id;
  bool read;

  Message(
      {this.createdAt, this.channel, this.text, this.user, this.styled, this.id, this.read});

  Message.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    channel =
    json['channel'] != null ? new Channel.fromJson(json['channel']) : null;
    text = json['text'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    styled = json['styled'];
    id = json['id'];
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    if (this.channel != null) {
      data['channel'] = this.channel.toJson();
    }
    data['text'] = this.text;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['styled'] = this.styled;
    data['id'] = this.id;
    data['read'] = this.read;
    return data;
  }
}

class User {
  Null override;
  String discord;
  int shouts;
  int id;
  String username;
  String styled;
  int group;

  User(
      {this.override, this.discord, this.shouts, this.id, this.username, this.styled, this.group});

  User.fromJson(Map<String, dynamic> json) {
    override = json['override'];
    discord = json['discord'];
    shouts = json['shouts'];
    id = json['id'];
    username = json['username'];
    styled = json['styled'];
    group = json['group'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['override'] = this.override;
    data['discord'] = this.discord;
    data['shouts'] = this.shouts;
    data['id'] = this.id;
    data['username'] = this.username;
    data['styled'] = this.styled;
    data['group'] = this.group;
    return data;
  }
}