import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/utils/image_utils.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  // final _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStream => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _db.collection(AppConstants.usersCol).doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, user.uid);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String contactNumber,
    required String address,
    required String gender,
    DateTime? birthdate,
    File? idImage,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    String? idUrl;
    if (idImage != null) {
      idUrl = await ImageUtils.toBase64(idImage);
      if (idUrl == "TOO_LARGE") {
        throw Exception('too large');
      }
    }

    final user = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      contactNumber: contactNumber,
      address: address,
      gender: gender,
      birthdate: birthdate,
      idImageUrl: idUrl,
    );

    await _db.collection(AppConstants.usersCol).doc(uid).set(user.toMap());
    return user;
  }

  Future<UserModel?> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getCurrentUserModel();
  }

  Future<void> logout() => _auth.signOut();

  Future<void> updateUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCol)
        .doc(user.uid)
        .update(user.toMap());
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // Future<String> _uploadFile(File file, String path) async {
  //   final ref = _storage.ref(path);
  //   await ref.putFile(file);
  //   return ref.getDownloadURL();
  // }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    final uid = user.uid;
    // Delete Firestore user document
    await _db.collection(AppConstants.usersCol).doc(uid).delete();
    // Delete Firebase Auth account
    await user.delete();
  }

}
