class Room {
  String name;
  Room(this.name);

  Room.fromJson(Map<String, dynamic> json) {
    name = json['Name']; //todo look later
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
