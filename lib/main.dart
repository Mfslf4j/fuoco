import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    var isWide = MediaQuery.of(context).size.width > 600;

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
                        width: isWide ? 320 : 200,
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

// Custom Profile Selector Widget
class ProfileSelector extends StatelessWidget {
  final String selectedProfile;
  final Function(String) onProfileChanged;

  const ProfileSelector({
    super.key,
    required this.selectedProfile,
    required this.onProfileChanged,
  });

  static const Map<String, String> profileIcons = {
    'Matteo': 'https://cdn-icons-png.flaticon.com/128/1211/1211015.png',
    'Sara': 'https://cdn-icons-png.flaticon.com/128/7665/7665682.png',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Neutral light grey background
          borderRadius: BorderRadius.circular(8), // Softer corners
          border: Border.all(color: Colors.grey[400]!, width: 1), // Subtle border
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              profileIcons[selectedProfile]!,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              selectedProfile,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 0, 0), // Adjust as needed
      items: profileIcons.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Image.network(
                entry.value,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 10),
              Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onTap: () => onProfileChanged(entry.key),
        );
      }).toList(),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
    );
  }
}