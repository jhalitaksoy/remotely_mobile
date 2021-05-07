class Room {
  int id;
  String name;
  Room(this.id, this.name);

  Room.fromJson(Map<String, dynamic> json) {
    name = json['Name']; //todo look later
    id = json['ID']; //todo look later
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    return data;
  }
}
