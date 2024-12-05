class FavoriteModel {
  final String userId;
  final int movieId;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final int voteCount;
  
  FavoriteModel({
    required this.userId,
    required this.movieId,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    required this.voteCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'title': title,
      'posterPath': posterPath,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      userId: map['userId'],
      movieId: map['movieId'],
      title: map['title'],
      posterPath: map['posterPath'],
      voteAverage: map['voteAverage'],
      voteCount: map['voteCount'],
    );
  }
}