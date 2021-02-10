class Auth {

  static Map<String, dynamic> tempLoginCheck(String email, String password) {
    if (email == "barry@earsman.com" && password == "sa2121") {
      return {"id": "TempId"};
    }
    throw "Invalid login";
  }
}