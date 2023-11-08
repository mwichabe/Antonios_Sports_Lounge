class UserModelOne {
  String uid;
  String? yourName;
  String? email;
  String? phoneNumber;
  String? profilePictureUrl;
  String? resident;
  String? hobbies;
  String? favouriteDrink;

  UserModelOne(
      {
        required this.uid,
        this.yourName,
        this.email,
        this.phoneNumber,
        this.profilePictureUrl,
        this.favouriteDrink,
        this.hobbies,
        this.resident,
      });
  // data from server
  factory UserModelOne.fromMap(map) {
    return UserModelOne(
      uid: map['uid'],
      yourName: map['yourName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profilePictureUrl: map['profilePictureUrl'],
      favouriteDrink: map['favouriteDrink'],
      resident: map['resident'],
      hobbies: map['hobbies'],
    );
  }
// sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'yourName': yourName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'favouriteDrink': favouriteDrink,
      'resident': resident,
      'hobbies': hobbies,
    };
  }
}