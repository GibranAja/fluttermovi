import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movi/movie/models/favorite_model.dart';

class FavoriteService {
  final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

  Stream<List<FavoriteModel>> getFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    try {
      // Query favorites where userId matches current user
      return favoritesCollection
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            print('Got ${snapshot.docs.length} favorites'); // Debug print
            return snapshot.docs.map((doc) {
              try {
                return FavoriteModel.fromMap(doc.data());
              } catch (e) {
                print('Error parsing favorite: $e'); // Debug print
                return null;
              }
            })
            .where((element) => element != null)
            .cast<FavoriteModel>()
            .toList();
          });
    } catch (e) {
      print('Error getting favorites stream: $e'); // Debug print
      return Stream.value([]);
    }
  }

  Future<void> addFavorite(FavoriteModel favorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to add favorites');
    }

    try {
      final documentId = '${user.uid}_${favorite.movieId}';
      await favoritesCollection.doc(documentId).set(favorite.toMap());
      print('Added favorite: $documentId'); // Debug print
    } catch (e) {
      print('Error adding favorite: $e'); // Debug print
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String userId, int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to remove favorites');
    }

    try {
      final documentId = '${userId}_$movieId';
      await favoritesCollection.doc(documentId).delete();
      print('Removed favorite: $documentId'); // Debug print
    } catch (e) {
      print('Error removing favorite: $e'); // Debug print
      throw Exception('Failed to remove favorite: $e');
    }
  }

  Future<bool> isFavorite(int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final documentId = '${user.uid}_$movieId';
      final doc = await favoritesCollection.doc(documentId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e'); // Debug print
      return false;
    }
  }
}
