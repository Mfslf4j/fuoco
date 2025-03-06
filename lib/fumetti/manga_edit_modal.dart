import 'package:flutter/material.dart';

class MangaEditModal extends StatefulWidget {
  final Map<String, dynamic> comic;
  final Function(Map<String, dynamic>)? onSave;
  final String selectedProfile;

  const MangaEditModal({
    super.key,
    required this.comic,
    this.onSave,
    required this.selectedProfile,
  });

  @override
  _MangaEditModalState createState() => _MangaEditModalState();
}

class _MangaEditModalState extends State<MangaEditModal> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _volumesController;
  late TextEditingController _boughtVolumesController;
  late TextEditingController _lastReadVolumeController;
  late TextEditingController _coverUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comic['title'] ?? '');
    _authorController =
        TextEditingController(text: widget.comic['author'] ?? '');
    _volumesController = TextEditingController(
      text: widget.comic['volumes']?.toString() ?? '',
    );
    _boughtVolumesController = TextEditingController(
      text: widget.comic['bought_volumes'] ?? '',
    );
    _lastReadVolumeController = TextEditingController(
      text: widget.comic['last_read_volume_${widget.selectedProfile.toLowerCase()}']?.toString() ?? '',
    );
    _coverUrlController = TextEditingController(
      text: widget.comic['cover_url'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _volumesController.dispose();
    _boughtVolumesController.dispose();
    _lastReadVolumeController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica Manga'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titolo'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Autore'),
            ),
            TextField(
              controller: _volumesController,
              decoration: const InputDecoration(labelText: 'Numero di volumi'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _boughtVolumesController,
              decoration: const InputDecoration(
                labelText: 'Volumi acquistati (es. 1,2,3)',
              ),
            ),
            TextField(
              controller: _lastReadVolumeController,
              decoration: const InputDecoration(
                labelText: 'Ultimo volume letto',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _coverUrlController,
              decoration: const InputDecoration(labelText: 'URL copertina'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Salva')),
      ],
    );
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Il titolo è obbligatorio')),
      );
      return;
    }

    final int? volumes = int.tryParse(_volumesController.text);
    final int? lastReadVolume = int.tryParse(_lastReadVolumeController.text);

    if (volumes != null && volumes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il numero di volumi deve essere maggiore di 0'),
        ),
      );
      return;
    }

    if (lastReadVolume != null && volumes != null && lastReadVolume > volumes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'L\'ultimo volume letto non può superare il numero totale di volumi',
          ),
        ),
      );
      return;
    }

    final updatedComic = Map<String, dynamic>.from(widget.comic)
      ..addAll({
        'title': _titleController.text,
        'author': _authorController.text,
        'volumes': volumes ?? widget.comic['volumes'],
        'bought_volumes': _boughtVolumesController.text,
        'last_read_volume_${widget.selectedProfile.toLowerCase()}':
        lastReadVolume ??
            widget.comic[
            'last_read_volume_${widget.selectedProfile.toLowerCase()}'],
        'cover_url': _coverUrlController.text,
      });

    if (widget.onSave != null) {
      widget.onSave!(updatedComic);
    }

    Navigator.pop(context);
  }
}