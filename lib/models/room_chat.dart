class DataChannelUser {
  int id;
  String name;

  DataChannelUser({this.id, this.name});

  DataChannelUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class ChatMessage {
  String text;
  DataChannelUser user;

  ChatMessage({this.text, this.user});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    user = json['user'] != null
        ? new DataChannelUser.fromJson(json['user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}
