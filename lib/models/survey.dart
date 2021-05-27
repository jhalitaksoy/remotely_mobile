class Survey {
  int ID;
  String text;
  List<Option> options;
  int participantCount;

  Survey({this.ID, this.text, this.participantCount, this.options});

  Survey.fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    text = json['text'];
    participantCount = json['participantCount'];
    if (json['options'] != null) {
      options = new List<Option>();
      json['options'].forEach((v) {
        options.add(new Option.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.ID;
    data['text'] = this.text;
    data['participantCount'] = this.participantCount;
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Option {
  int id;
  String text;
  int count;

  Option({this.id, this.text, this.count});

  Option.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['count'] = this.count;
    return data;
  }
}
