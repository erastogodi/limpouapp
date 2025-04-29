class UserModel {
  String id;
  String name;
  String email;
  String phone;
  String aboutMe;
  List<String> availability;
  String userType;
  String profilePicture;

  // 🔹 Novos campos de localização legível
  double? latitude;
  double? longitude;
  String? street;
  String? neighborhood;
  String? city;
  String? state;
  String? country;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.aboutMe,
    required this.availability,
    required this.userType,
    required this.profilePicture,
    this.latitude,
    this.longitude,
    this.street,
    this.neighborhood,
    this.city,
    this.state,
    this.country,
  });

  /// 🔁 Converte um Map do Firestore para um objeto UserModel
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
      availability: List<String>.from(data['availability'] ?? []),
      userType: data['userType'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      street: data['street'],
      neighborhood: data['neighborhood'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
    );
  }

  /// 🔁 Converte um objeto UserModel para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'aboutMe': aboutMe,
      'availability': availability,
      'userType': userType,
      'profilePicture': profilePicture,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'country': country,
    };
  }
}
