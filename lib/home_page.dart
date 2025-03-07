import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fuoco/profile_selector.dart';
import 'package:fuoco/fumetti/manga_card.dart';
import 'package:fuoco/providers/comic_provider.dart';
import 'package:fuoco/stats_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.stop(); // Ferma l'animazione prima della dispose
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimations(int cardCount) {
    // Ferma e resetta il controller se è in esecuzione
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.reset();

    // Imposta la durata in base al numero di card
    final int totalDurationMs = cardCount * 100; // 100ms per card
    _controller.duration = Duration(milliseconds: totalDurationMs);

    // Genera le animazioni
    _animations = List.generate(
      cardCount,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / cardCount, // Ritardo proporzionale
            (index + 1) / cardCount, // Fine proporzionale
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    // Avvia l'animazione
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('La mia collezione Manga'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsPage()),
                );
              },
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: const Text(
                'Statistiche',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<ComicProvider>(
              builder: (context, provider, child) => ProfileSelector(
                selectedProfile: provider.selectedProfile,
                onProfileChanged: provider.setProfile,
              ),
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
              onChanged: (value) =>
                  Provider.of<ComicProvider>(context, listen: false).filter(value),
            ),
          ),
          Expanded(
            child: Consumer<ComicProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text('Errore: ${provider.error}'));
                }
                if (provider.filteredMangaList.isEmpty) {
                  return const Center(child: Text('Nessun dato disponibile'));
                }

                // Aggiorna le animazioni quando la lista cambia
                _updateAnimations(provider.filteredMangaList.length);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: provider.filteredMangaList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final comic = entry.value;
                      return AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          return Opacity(
                            opacity: _animations[index].value,
                            child: Transform.scale(
                              scale: 0.8 + (_animations[index].value * 0.2), // Da 0.8 a 1.0
                              child: SizedBox(
                                width: _getWrapCardWidth(MediaQuery.of(context).size.width),
                                child: MangaCard(
                                  comic: comic,
                                  onComicUpdated: provider.updateComic,
                                  selectedProfile: provider.selectedProfile,
                                ),
                              ),
                            ),
                          );
                        },
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
}