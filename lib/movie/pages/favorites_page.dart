import 'package:flutter/material.dart';
import 'package:movi/movie/models/favorite_model.dart';
import 'package:movi/movie/pages/movie_detail_page.dart';
import 'package:movi/movie/services/favorite_service.dart';
import 'package:movi/widget/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final favoriteService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('Please login to view favorites'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<FavoriteModel>>(
        stream: favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Add debug prints
          if (snapshot.hasError) {
            print('Error in favorites stream: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No favorites data available');
            return const Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          print('Displaying ${snapshot.data!.length} favorites');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final favorite = snapshot.data![index];
              return Dismissible(
                key: Key(favorite.movieId.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you want to remove this favorite?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("DELETE"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await favoriteService.removeFavorite(
                        user.uid,
                        favorite.movieId,
                      );
                      
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorite removed successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error removing favorite: ${e.toString()}'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(id: favorite.movieId),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ImageNetworkWidget(
                            imageSrc: favorite.posterPath,
                            height: 120,
                            width: 80,
                            radius: 10,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  favorite.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    Text(
                                      ' ${favorite.voteAverage} (${favorite.voteCount})',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
