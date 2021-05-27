class RegisterParameters {
  String name;
  String password;

  RegisterParameters({this.name, this.password});

  RegisterParameters.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['password'] = this.password;
    return data;
  }
}

class LoginParameters {
  String name;
  String password;

  LoginParameters({this.name, this.password});

  LoginParameters.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['password'] = this.password;
    return data;
  }
}

class LoginResult {
  int id;
  String name;
  String jwtToken;

  LoginResult({this.id, this.name, this.jwtToken});

  LoginResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    jwtToken = json['jwt_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['jwt_token'] = this.jwtToken;
    return data;
  }
}
