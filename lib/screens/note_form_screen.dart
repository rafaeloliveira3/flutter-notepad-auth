import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/note.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;
  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _client = Supabase.instance.client;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _loading = true);

    final isEditing = widget.note != null;
    final Map<String, dynamic> payload = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      if (!isEditing) 'user_id': _client.auth.currentUser!.id,
    };

    final data = isEditing
        ? await _client
            .from('notes')
            .update(payload)
            .eq('id', widget.note!.id)
            .select()
            .single()
        : await _client.from('notes').insert(payload).select().single();

    if (mounted) Navigator.pop(context, Note.fromMap(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nova Nota' : 'Editar Nota'),
        actions: [
          IconButton(
            icon: _loading
                ? const CircularProgressIndicator()
                : const Icon(Icons.check),
            onPressed: _loading ? null : _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Conteúdo'),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              minLines: 5,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
            ),
            if (widget.note != null) ...[
              const SizedBox(height: 16),
              Text(
                'Criado em: ${_formatDate(widget.note!.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Atualizado em: ${_formatDate(widget.note!.updatedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
