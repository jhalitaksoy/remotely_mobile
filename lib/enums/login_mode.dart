enum LoginMode {
  //todo : need better name
  Login,
  Register,
}

extension LoginModeExtension on LoginMode {
  LoginMode switchMode() {
    switch (this) {
      case LoginMode.Register:
        return LoginMode.Login;
      case LoginMode.Login:
        return LoginMode.Register;
      default:
        return LoginMode.Login;
    }
  }
}
