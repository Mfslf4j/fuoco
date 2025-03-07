import 'package:flutter/material.dart';
import '../repositories/comic_repository.dart';

class ComicProvider with ChangeNotifier {
  final ComicRepository _comicRepository = ComicRepository();
  String _selectedProfile = 'Matteo';
  List<Map<String, dynamic>> _allComics = [];
  List<Map<String, dynamic>> _filteredMangaList = [];
  bool _isLoading = false;
  String? _error;

  String get selectedProfile => _selectedProfile;

  List<Map<String, dynamic>> get filteredMangaList => _filteredMangaList;

  bool get isLoading => _isLoading;

  String? get error => _error;

  ComicProvider() {
    fetchComics();
  }

  Future<void> fetchComics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _allComics = await _comicRepository.fetchComics();
      _filteredMangaList = List.from(_allComics);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get allComics => _allComics;

  void setProfile(String profile) {
    if (_selectedProfile != profile) {
      _selectedProfile = profile;
      fetchComics(); // Ricarica i dati per il nuovo profilo
    }
  }

  void filter(String query) {
    _filteredMangaList =
        _allComics.where((manga) {
          final title = manga['title']?.toString().toLowerCase() ?? '';
          final author = manga['author']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) ||
              author.contains(query.toLowerCase());
        }).toList();
    notifyListeners();
  }

  Future<void> updateComic(Map<String, dynamic> updatedComic) async {
    try {
      await _comicRepository.updateComic(updatedComic, _selectedProfile);
      final index = _allComics.indexWhere(
        (comic) => comic['id'] == updatedComic['id'],
      );
      if (index != -1) {
        _allComics[index] = updatedComic;
        filter(''); // Aggiorna la lista filtrata
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
