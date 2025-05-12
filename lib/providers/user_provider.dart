import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> uploadProfilePicture(File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Usuário não autenticado");

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${currentUser.uid}/profile.jpg');

      // ⬆️ Upload da imagem
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 🔁 Atualiza no Firestore e no modelo local
      await _firestore.collection('users').doc(currentUser.uid).update({
        'profilePicture': downloadUrl,
      });

      if (user != null) {
        user!.profilePicture = downloadUrl;
        notifyListeners();
      }
    } catch (e) {
      print("Erro ao fazer upload da imagem de perfil: $e");
      rethrow;
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

  Future<void> adicionarDiaristasSimuladas() async {
    final baseLat = user?.latitude ?? 0.0;
    final baseLon = user?.longitude ?? 0.0;

    final List<int> raios = [10, 20, 30, 40, 50];

    for (int km in raios) {
      final deslocamentoLat = km / 111.0;
      final deslocamentoLon = km / (111.0 * cos(baseLat * pi / 180));

      final lat = baseLat + deslocamentoLat;
      final lon = baseLon + deslocamentoLon;

      final docRef = _firestore.collection("users").doc();

      final diarista = {
        'name': 'Diarista ${km}km',
        'email': 'diarista${km}@teste.com',
        'phone': '99999-000$km',
        'aboutMe': 'Diarista com disponibilidade a $km km',
        'availability': ['segunda', 'sexta'],
        'userType': 'Doméstica',
        'profilePicture': '',
        'latitude': lat,
        'longitude': lon,
        'street': 'Rua Simulada $km',
        'neighborhood': 'Bairro $km',
        'city': 'Cidade Exemplo',
        'state': 'Estado',
        'country': 'Brasil',
      };

      await docRef.set(diarista);

      final diaristaId = docRef.id;

      // ➕ Simular avaliações reais (3 a 5)
      for (int i = 0; i < 3 + Random().nextInt(3); i++) {
        await _firestore.collection('avaliacoes').add({
          'avaliacaoId': '',
          'agendamentoId': '',
          'avaliadorId': 'simulado',
          'avaliadoId': diaristaId,
          'nota': 3 + Random().nextInt(3), // 3 a 5
          'comentario': 'Boa diarista.',
          'data': Timestamp.now(),
        });
      }

      // ➕ Simular agendamentos finalizados (5 a 10)
      for (int i = 0; i < 5 + Random().nextInt(6); i++) {
        await _firestore.collection('agendamentos').add({
          'serviceId': '',
          'propertyId': '',
          'createdBy': 'simulado',
          'contractorId': 'simulado_contratante',
          'workerId': diaristaId,
          'status': 'finalizado',
          'price': 120.0,
          'paymentConfirmed': true,
          'serviceDate': DateTime.now().subtract(Duration(days: i * 5)),
          'createdAt': DateTime.now().subtract(Duration(days: i * 5 + 1)),
          'notes': 'Serviço concluído com sucesso',
          'confirmedByWorker': true,
          'confirmedByContractor': true,
        });
      }
    }
  }
}
