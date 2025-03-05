import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fumetti/manga_card.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://fsjuzwrlfnysgnooynkc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzanV6d3JsZm55c2dub295bmtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwOTQzMzgsImV4cCI6MjA1NjY3MDMzOH0.yDmB2xW8I7ynIszpSLG-l3vrooTl8tmeWOgwL84jkko',
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
  late Future<List<dynamic>> _future;
  List<Map<String, dynamic>> allComics = [];
  List<Map<String, dynamic>> filteredMangaList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client.from('comics').select().then((response) => response as List<dynamic>);
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

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calcola il numero di colonne in base a una larghezza minima per colonna
    const minColumnWidth = 180.0; // Larghezza minima per ogni card
    return (screenWidth / minColumnWidth).floor().clamp(1, 6); // Min 1, max 6 colonne
  }

  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(context);
    final columnWidth = (screenWidth - (crossAxisCount - 1) * 8) / crossAxisCount;
    const imageHeightRatio = 1.4; // Altezza immagine
    const textHeightRatio = 0.35; // Leggermente aumentato per icone e testo
    final progressBarHeight = MediaQuery.of(context).size.width > 300 ? 25.0 : 20.0;
    final progressHeightRatio = progressBarHeight / columnWidth;
    var totalHeightRatio = imageHeightRatio + textHeightRatio + progressHeightRatio; // ≈ 1.9
    return columnWidth / (columnWidth * totalHeightRatio); // ≈ 0.53
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La mia collezione Manga'),
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
            child: FutureBuilder<List<dynamic>>(
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

                allComics = snapshot.data!.map((e) => e as Map<String, dynamic>).toList();
                // Inizializza filteredMangaList con tutti i comics se non è stata ancora filtrata
                if (filteredMangaList.isEmpty && _searchController.text.isEmpty) {
                  filteredMangaList = List.from(allComics);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: _getChildAspectRatio(context),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredMangaList.length,
                  itemBuilder: (context, index) {
                    final comic = filteredMangaList[index];
                    return MangaCard(comic: comic);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}