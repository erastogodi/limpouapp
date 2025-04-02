class UserModel {
  String id;
  String name;
  String email;
  String phone;
  String aboutMe;
  List<String> availability;
  String userType;
  String profilePicture;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.aboutMe,
    required this.availability,
    required this.userType,
    required this.profilePicture,
  });

  /// **🔹 Converte um Map do Firestore para um objeto `UserModel`**
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
      availability: List<String>.from(data['availability'] ?? []),
      userType: data['userType'] ?? '', // ✅ Agora armazenamos o tipo do usuário
      profilePicture: data['profilePicture'] ?? '',
    );
  }

  /// **🔹 Converte um objeto `UserModel` para um Map que pode ser salvo no Firestore**
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "aboutMe": aboutMe,
      "availability": availability,
      "userType": userType,
      "profilePicture": profilePicture,
    };
  }
}
