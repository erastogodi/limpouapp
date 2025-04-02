import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **🔥 REGISTRO DE NOVO USUÁRIO**
  Future<UserCredential> signUp({
    required String name,
    required String cpf,
    required String phone,
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar os dados do usuário no Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name,
        "cpf": cpf,
        "phone": phone,
        "email": email,
        "userType": userType,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw Exception("Erro ao registrar: $e");
    }
  }

  /// **✅ LOGIN DE USUÁRIO**
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } catch (e) {
      throw Exception("Erro ao fazer login: $e");
    }
  }

  /// **🔍 BUSCAR O TIPO DE USUÁRIO NO FIRESTORE**
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();
      return userDoc.exists ? userDoc["userType"] as String? : null;
    } catch (e) {
      throw Exception("Erro ao buscar tipo de usuário: $e");
    }
  }

  /// **🚪 LOGOUT DO USUÁRIO**
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// **👤 PEGAR O USUÁRIO LOGADO ATUALMENTE**
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
