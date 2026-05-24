import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/note.dart';
import '../widgets/note_card.dart';
import 'login_screen.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _client = Supabase.instance.client;
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final data = await _client
        .from('notes')
        .select()
        .eq('user_id', _client.auth.currentUser!.id)
        .order('updated_at', ascending: false);
    if (mounted) {
      setState(() {
        _notes = (data as List).map((e) => Note.fromMap(e)).toList();
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
    setState(() => _notes.removeWhere((n) => n.id == id));
  }

  Future<void> _openForm({Note? note}) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
    );
    if (result != null) {
      setState(() {
        if (note == null) {
          _notes.insert(0, result);
        } else {
          final i = _notes.indexWhere((n) => n.id == result.id);
          if (i != -1) _notes[i] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem Vindo!'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child:
                Text('Logado Como: ${_client.auth.currentUser?.email ?? ''}'),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_notes.isEmpty)
            const Expanded(
              child:
                  Center(child: Text('Nenhuma nota. Toque em + para criar!')),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNotes,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => NoteCard(
                    note: _notes[i],
                    onTap: () => _openForm(note: _notes[i]),
                    onDelete: () => _deleteNote(_notes[i].id),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
