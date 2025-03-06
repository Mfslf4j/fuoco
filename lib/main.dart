import 'package:flutter/material.dart';
import 'package:fuoco/profile_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fumetti/manga_card.dart';
import 'fumetti/comic_repository.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://fsjuzwrlfnysgnooynkc.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzanV6d3JsZm55c2dub295bmtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwOTQzMzgsImV4cCI6MjA1NjY3MDMzOH0.yDmB2xW8I7ynIszpSLG-l3vrooTl8tmeWOgwL84jkko',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MyHomePage(title: 'Fuoco'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> allComics = [];
  List<Map<String, dynamic>> filteredMangaList = [];
  final TextEditingController _searchController = TextEditingController();
  final ComicRepository _comicRepository = ComicRepository();
  String selectedProfile = 'Matteo'; // Default profile

  @override
  void initState() {
    super.initState();
    _future = _comicRepository.fetchComics();
    _searchController.addListener(_filterManga);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterManga() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMangaList = allComics.where((manga) {
        final title = manga['title']?.toString().toLowerCase() ?? '';
        final author = manga['author']?.toString().toLowerCase() ?? '';
        return title.contains(query) || author.contains(query);
      }).toList();
    });
  }

  Future<void> _updateComic(Map<String, dynamic> updatedComic) async {
    try {
      await _comicRepository.updateComic(updatedComic, selectedProfile);
      setState(() {
        final index = allComics.indexWhere(
              (comic) => comic['id'] == updatedComic['id'],
        );
        if (index != -1) {
          allComics[index] = updatedComic;
        }
        _filterManga();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manga aggiornato con successo')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _changeProfile(String newProfile) {
    if (newProfile != selectedProfile) {
      setState(() {
        selectedProfile = newProfile;
        _future = _comicRepository.fetchComics(); // Refresh data
        filteredMangaList.clear(); // Clear filtered list to force rebuild
      });
    }
  }

  double _getWrapCardWidth(double width) {
    var widthStep = 300;
    var margin = 8;

    if (width > widthStep * 6) {
      return (width - 8 * margin) / 7;
    } else if (width > widthStep * 5) {
      return (width - 7 * margin) / 6;
    } else if (width > widthStep * 4) {
      return (width - 6 * margin) / 5;
    } else if (width > widthStep * 3) {
      return (width - 5 * margin) / 4;
    } else if (width > widthStep * 2) {
      return (width - 4 * margin) / 3;
    } else if (width > widthStep) {
      return (width - 3 * margin) / 2;
    }
    return (width - 2 * margin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La mia collezione Manga'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ProfileSelector(
              selectedProfile: selectedProfile,
              onProfileChanged: _changeProfile,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca per nome o autore...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessun dato disponibile'));
                }

                allComics = snapshot.data!;
                if (filteredMangaList.isEmpty &&
                    _searchController.text.isEmpty) {
                  filteredMangaList = List.from(allComics);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: filteredMangaList.map((comic) {
                      return SizedBox(
                        width: _getWrapCardWidth(MediaQuery.of(context).size.width),
                        child: MangaCard(
                          comic: comic,
                          onComicUpdated: _updateComic,
                          selectedProfile: selectedProfile,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}