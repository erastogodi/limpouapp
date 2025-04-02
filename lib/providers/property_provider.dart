import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PropertyProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProperty({
    required String propertyType,
    required String spaceType,
    required String address,
    required String city,
    required String state,
    required String cep,
    required String date,
    required String bedrooms,
    required String bathrooms,
    required String size,
    required List<String> areasToClean,
    required bool materialsProvided,
  }) async {
    try {
      // 🔥 Obtendo o usuário autenticado
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      // 🔥 Criando referência ao documento do usuário
      DocumentReference userRef = _firestore.collection("users").doc(user.uid);

      // 🔥 Criando referência à coleção de imóveis dentro do usuário
      CollectionReference propertiesRef = userRef.collection("properties");

      // 🔥 Adicionando os dados do imóvel
      await propertiesRef.add({
        "userId": user.uid, // Associando o imóvel ao usuário
        "propertyType": propertyType,
        "spaceType": spaceType,
        "address": address,
        "city": city,
        "state": state,
        "cep": cep,
        "date": date,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "size": size,
        "areasToClean": areasToClean,
        "materialsProvided": materialsProvided ? "Sim" : "Não",
        "createdAt": FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao adicionar imóvel: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUserProperties() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("properties")
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception("Erro ao obter propriedades: $e");
    }
  }

  Future<void> updateProperty({
    required String id,
    required String propertyType,
    required String spaceType,
    required String address,
    required String city,
    required String state,
    required String cep,
    required String date,
    required String bedrooms,
    required String bathrooms,
    required String size,
    required List<String> areasToClean,
    required bool materialsProvided,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("properties")
          .doc(id)
          .update({
        "propertyType": propertyType,
        "spaceType": spaceType,
        "address": address,
        "city": city,
        "state": state,
        "cep": cep,
        "date": date,
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "size": size,
        "areasToClean": areasToClean,
        "materialsProvided": materialsProvided ? "Sim" : "Não",
        "updatedAt": FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao atualizar imóvel: $e");
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("properties")
          .doc(id)
          .delete();

      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao excluir imóvel: $e");
    }
  }

  Future<Map<String, dynamic>> getPropertyById(String id) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      DocumentSnapshot snapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("properties")
          .doc(id)
          .get();

      if (snapshot.exists) {
        return {...snapshot.data() as Map<String, dynamic>, "id": snapshot.id};
      } else {
        throw Exception("Imóvel não encontrado.");
      }
    } catch (e) {
      throw Exception("Erro ao buscar imóvel: $e");
    }
  }
}
