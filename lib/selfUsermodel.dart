class SelfuserModel {
  Data data;

  SelfuserModel({this.data});

  SelfuserModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  User user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
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
      {this.override,
        this.discord,
        this.shouts,
        this.id,
        this.username,
        this.styled,
        this.group});

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