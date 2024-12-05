import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movi/movie/models/favorite_model.dart';

class FavoriteService {
  final favoritesCollection = FirebaseFirestore.instance.collection('favorites');
  
  Future<void> addFavorite(FavoriteModel favorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to add favorites');
    }
    
    try {
      final docRef = favoritesCollection.doc('${favorite.userId}_${favorite.movieId}');
      await docRef.set(favorite.toMap());
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to remove favorites');
    }
    
    try {
      await favoritesCollection.doc('${userId}_$movieId').delete();
    } catch (e) {
      print('Error removing favorite: $e'); 
      rethrow;
    }
  }

  Future<bool> isFavorite(int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    try {
      final docSnapshot = await favoritesCollection
          .doc('${user.uid}_$movieId')
          .get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Stream<List<FavoriteModel>> getFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    try {
      return favoritesCollection
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => 
              FavoriteModel.fromMap(doc.data())
            ).toList();
          });
    } catch (e) {
      print('Error getting favorites: $e');
      return Stream.value([]);
    }
  }
}