import 'package:flutter/material.dart';
import 'package:fuoco/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:fuoco/profile_selector.dart';
import 'package:fuoco/fumetti/manga_card.dart';
import 'package:fuoco/providers/comic_provider.dart';
import 'package:fuoco/stats_page.dart';

import 'fumetti/animated_manga_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>> _animations = [];
  bool _isFirstLoad = true; // Flag per tracciare il primo caricamento

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Inizializza le animazioni solo al primo caricamento
  void _initializeAnimations(int cardCount) {
    if (!_isFirstLoad) return; // Esci se non è il primo caricamento

    _controller.duration = Duration(milliseconds: cardCount * AppConstants.animationDurationPerCardMs);
    _animations = List.generate(
      cardCount,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / cardCount,
            (index + 1) / cardCount,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    if (mounted) {
      _controller.forward().then((_) => _isFirstLoad = false); // Imposta il flag a false dopo l'animazione
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Costruisce l'AppBar con titolo e azioni
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('La mia collezione Manga'),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        _buildStatsButton(context),
        _buildProfileSelector(context),
      ],
    );
  }

  /// Pulsante per navigare alla pagina delle statistiche
  Widget _buildStatsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatsPage()),
        ),
        icon: Icon(Icons.bar_chart, color: Theme.of(context).secondaryHeaderColor),
        label: Text(
          'Statistiche',
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ),
    );
  }

  /// Selettore del profilo con Consumer
  Widget _buildProfileSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<ComicProvider>(
        builder: (context, provider, child) => ProfileSelector(
          selectedProfile: provider.selectedProfile,
          onProfileChanged: provider.setProfile,
        ),
      ),
    );
  }

  /// Costruisce il corpo della pagina con campo di ricerca e lista
  Widget _buildBody(BuildContext context) {
    final searchController = TextEditingController();

    return Column(
      children: [
        _buildSearchField(context, searchController),
        Expanded(child: _buildMangaList(context)),
      ],
    );
  }

  /// Campo di ricerca per filtrare i manga
  Widget _buildSearchField(BuildContext context, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Cerca per nome o autore...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) => Provider.of<ComicProvider>(context, listen: false).filter(value),
      ),
    );
  }

  /// Lista dei manga con animazioni
  Widget _buildMangaList(BuildContext context) {
    return Consumer<ComicProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.error != null) return Center(child: Text('Errore: ${provider.error}'));
        if (provider.filteredMangaList.isEmpty) return const Center(child: Text('Nessun dato disponibile'));

        // Inizializza le animazioni solo al primo caricamento
        if (_isFirstLoad) {
          _initializeAnimations(provider.filteredMangaList.length);
        }

        final cardWidth = _calculateCardWidth(MediaQuery.of(context).size.width);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.wrapSpacing),
          child: Wrap(
            spacing: AppConstants.wrapSpacing,
            runSpacing: AppConstants.wrapRunSpacing,
            alignment: WrapAlignment.start,
            children: provider.filteredMangaList.asMap().entries.map((entry) {
              final index = entry.key;
              final comic = entry.value;
              return AnimatedMangaCard(
                animation: _isFirstLoad && index < _animations.length ? _animations[index] : const AlwaysStoppedAnimation(1.0),
                mangaCard: MangaCard(
                  comic: comic,
                  onComicUpdated: provider.updateComic,
                  selectedProfile: provider.selectedProfile,
                ),
                cardWidth: cardWidth,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Calcola la larghezza delle card in base alla larghezza dello schermo
  double _calculateCardWidth(double screenWidth) {
    const margin = AppConstants.wrapSpacing;
    final columns = (screenWidth / AppConstants.widthStep).floor().clamp(1, AppConstants.maxColumns);
    return (screenWidth - (columns + 1) * margin) / columns;
  }
}