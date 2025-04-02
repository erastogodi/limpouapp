import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:limpou25k/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  UserModel? selectedUser;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **🔹 Busca os dados do usuário logado no Firestore**
  Future<void> fetchUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      DocumentSnapshot userDoc =
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

  /// **🔹 Busca um usuário específico pelo ID**
  Future<void> fetchUserById(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        selectedUser = UserModel.fromMap(
            userDoc.id, userDoc.data() as Map<String, dynamic>);
      } else {
        selectedUser = null;
      }
    } catch (e) {
      print("Erro ao buscar usuário pelo ID: $e");
      selectedUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// **🔹 Método para limpar `selectedUser` quando sair da página de perfil**
  void clearSelectedUser() {
    selectedUser = null;
    notifyListeners();
  }

  /// **🔹 Atualiza os dados do usuário no Firestore**
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

  List<UserModel> domesticas = [];

  /// **🔹 Busca todas as domésticas**
  Future<void> fetchDomesticas() async {
    try {
      isLoading = true;
      notifyListeners();

      final QuerySnapshot querySnapshot = await _firestore
          .collection("users")
          .where("userType",
              isEqualTo: "Doméstica") // 🔹 Filtra apenas domésticas
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        domesticas = querySnapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data is Map<String, dynamic>) {
                return UserModel.fromMap(doc.id, data);
              }
              return null;
            })
            .whereType<UserModel>()
            .toList();
      } else {
        domesticas = [];
      }
    } catch (e) {
      print("Erro ao buscar domésticas: $e");
      domesticas = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
