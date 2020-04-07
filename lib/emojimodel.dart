class EmojiModel {
  List<Emojis> emojis;

  EmojiModel({this.emojis});

  EmojiModel.fromJson(Map<String, dynamic> json) {
    if (json['emojis'] != null) {
      emojis = new List<Emojis>();
      json['emojis'].forEach((v) {
        emojis.add(new Emojis.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.emojis != null) {
      data['emojis'] = this.emojis.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Emojis {
  String typed;
  String image;

  Emojis({this.typed, this.image});

  Emojis.fromJson(Map<String, dynamic> json) {
    typed = json['typed'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typed'] = this.typed;
    data['image'] = this.image;
    return data;
  }
}