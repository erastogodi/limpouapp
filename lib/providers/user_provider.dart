import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:limpou25k/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  UserModel? selectedUser;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Busca dados do usuário logado
  Future<void> fetchUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final userDoc =
          await _firestore.collection("users").doc(currentUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        user = UserModel.fromMap(
            userDoc.id, userDoc.data() as Map<String, dynamic>);
      } else {
        user = null;
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Atualiza dados do usuário
  Future<void> updateUserData(UserModel updatedUser) async {
    try {
      await _firestore
          .collection("users")
          .doc(updatedUser.id)
          .update(updatedUser.toMap());
      user = updatedUser;
      notifyListeners();
    } catch (e) {
      print("Erro ao atualizar dados do usuário: $e");
    }
  }

  /// 🔹 Atualiza localização atual do usuário com endereço legível
  Future<void> atualizarLocalizacaoAtual() async {
    try {
      final loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      final loc.LocationData locData = await location.getLocation();

      if (user != null) {
        user!.latitude = locData.latitude ?? 0.0;
        user!.longitude = locData.longitude ?? 0.0;

        final placemarks = await placemarkFromCoordinates(
          user!.latitude!,
          user!.longitude!,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          user!.street = place.street ?? '';
          user!.neighborhood = place.subLocality ?? '';
          user!.city = place.locality ?? '';
          user!.state = place.administrativeArea ?? '';
          user!.country = place.country ?? '';
        }

        await _firestore.collection("users").doc(user!.id).update({
          'latitude': user!.latitude,
          'longitude': user!.longitude,
          'street': user!.street,
          'neighborhood': user!.neighborhood,
          'city': user!.city,
          'state': user!.state,
          'country': user!.country,
        });

        notifyListeners();
      }
    } catch (e) {
      print("Erro ao atualizar localização: $e");
    }
  }

  /// 🔹 Lista de domésticas
  List<UserModel> domesticas = [];

  Future<void> fetchDomesticas() async {
    try {
      isLoading = true;
      notifyListeners();

      final query = await _firestore
          .collection("users")
          .where("userType", isEqualTo: "Doméstica")
          .get();

      domesticas = query.docs
          .map((doc) {
            final data = doc.data();
            return UserModel.fromMap(doc.id, data);
          })
          .whereType<UserModel>()
          .toList();
    } catch (e) {
      print("Erro ao buscar domésticas: $e");
      domesticas = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Busca um usuário específico pelo ID
  Future<void> fetchUserById(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection("users").doc(userId).get();

      if (doc.exists && doc.data() != null) {
        selectedUser =
            UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        selectedUser = null;
      }
    } catch (e) {
      print("Erro ao buscar usuário por ID: $e");
      selectedUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Limpa usuário selecionado
  void clearSelectedUser() {
    selectedUser = null;
    notifyListeners();
  }
}
