import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fuoco/profile_selector.dart';
import 'package:fuoco/fumetti/manga_card.dart';
import 'package:fuoco/providers/comic_provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('La mia collezione Manga'),
        actions: [
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: provider.filteredMangaList.map((comic) {
                      return SizedBox(
                        width: _getWrapCardWidth(MediaQuery.of(context).size.width),
                        child: MangaCard(
                          comic: comic,
                          onComicUpdated: provider.updateComic,
                          selectedProfile: provider.selectedProfile,
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