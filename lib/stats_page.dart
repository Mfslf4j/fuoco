import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/comic_provider.dart';
import 'utils/progress_utils.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche Collezione'),
        backgroundColor: Colors.blue, // Blu come tema principale
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Errore: ${provider.error}'));
          }
          if (provider.allComics.isEmpty) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          final stats = _calculateStats(provider.allComics);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Matteo vs Sara',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                _buildComparisonCard(stats),
                const SizedBox(height: 20),
                const Text(
                  'Progresso Acquisti',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPurchaseProgress(stats),
                const SizedBox(height: 20),
                const Text(
                  'Statistiche Collezione',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCollectionStats(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> comics) {
    int matteoVolumesRead = 0;
    int saraVolumesRead = 0;
    int matteoCompleted = 0;
    int saraCompleted = 0;
    int totalVolumes = 0;
    int totalPurchased = 0;
    int completedSeries = 0;
    int incompleteSeries = 0;
    int neverRead = 0;

    for (var comic in comics) {
      final progressMatteo = ProgressUtils.calculateProgress(comic, 'Matteo');
      final progressSara = ProgressUtils.calculateProgress(comic, 'Sara');

      totalVolumes += (comic['volumes'] as num?)?.toInt() ?? 0;
      totalPurchased += (comic['bought_volumes']?.split(',')?.length as num?)?.toInt() ?? 0;

      matteoVolumesRead += (comic['last_read_volume_matteo'] as num?)?.toInt() ?? 0;
      saraVolumesRead += (comic['last_read_volume_sara'] as num?)?.toInt() ?? 0;

      if (progressMatteo['isCompleted']) matteoCompleted++;
      if (progressSara['isCompleted']) saraCompleted++;

      if (progressMatteo['isCompleted'] || progressSara['isCompleted']) {
        completedSeries++;
      } else if (progressMatteo['purchaseProgress'] > 0 || progressSara['purchaseProgress'] > 0) {
        incompleteSeries++;
      }
      if ((comic['last_read_volume_matteo'] as num?)?.toInt() == 0 &&
          (comic['last_read_volume_sara'] as num?)?.toInt() == 0) {
        neverRead++;
      }
    }

    final matteoScore = _calculateScore(matteoVolumesRead, matteoCompleted);
    final saraScore = _calculateScore(saraVolumesRead, saraCompleted);

    return {
      'totalVolumes': totalVolumes,
      'totalPurchased': totalPurchased,
      'matteo': {
        'volumesRead': matteoVolumesRead,
        'completed': matteoCompleted,
        'score': matteoScore,
      },
      'sara': {
        'volumesRead': saraVolumesRead,
        'completed': saraCompleted,
        'score': saraScore,
      },
      'completedSeries': completedSeries,
      'incompleteSeries': incompleteSeries,
      'neverRead': neverRead,
    };
  }

  int _calculateScore(int volumesRead, int completed) {
    return (volumesRead * 10) + (completed * 100);
  }

  Widget _buildComparisonCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComparisonRow('Volumi letti', stats['matteo']['volumesRead'], stats['sara']['volumesRead']),
            const Divider(),
            _buildComparisonRow('Serie completate', stats['matteo']['completed'], stats['sara']['completed']),
            const Divider(),
            _buildComparisonRow('Score', stats['matteo']['score'], stats['sara']['score']),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, int matteoValue, int saraValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              matteoValue.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              saraValue.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseProgress(Map<String, dynamic> stats) {
    final double progress = stats['totalPurchased'] / stats['totalVolumes'];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volumi acquistati: ${stats['totalPurchased']} / ${stats['totalVolumes']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 5),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% completato',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionStats(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Serie complete', stats['completedSeries'], Colors.green),
            _buildStatRow('Serie incomplete', stats['incompleteSeries'], Colors.orange),
            _buildStatRow('Mai lette', stats['neverRead'], Colors.red),
            _buildStatRow('Totale serie', stats['completedSeries'] + stats['incompleteSeries'], Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}