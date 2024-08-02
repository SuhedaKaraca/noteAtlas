import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_note_page.dart';
import 'new_note_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoteTypePage extends StatefulWidget {
  final String noteType;
  final Function(int) onNoteCountChanged;

  NoteTypePage({required this.noteType, required this.onNoteCountChanged});

  @override
  _NoteTypePageState createState() => _NoteTypePageState();
}

class _NoteTypePageState extends State<NoteTypePage> {
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesData = prefs.getString(widget.noteType);
    if (notesData != null) {
      List<dynamic> notesList = jsonDecode(notesData);
      notes = notesList.map((note) => Map<String, dynamic>.from(note)).toList();
      setState(() {});
    }
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.noteType, jsonEncode(notes));
  }

  void _addNewNote(String note, File? image) {
    setState(() {
      notes.add({'text': note, 'image': image?.path});
      widget.onNoteCountChanged(notes.length);
      _saveNotes();
    });
  }

  void _updateNote(int index, String updatedText, File? updatedImage) {
    setState(() {
      notes[index] = {'text': updatedText, 'image': updatedImage?.path};
      _saveNotes();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      widget.onNoteCountChanged(notes.length);
      _saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteType),
      ),
      body: Column(
        children: [
          if (notes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Yeni bir not ekleyin.',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index]['text']),
                  leading: notes[index]['image'] != null
                      ? Image.file(
                          File(notes[index]['image']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteNoteDialog(context, index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNotePage(
                          initialText: notes[index]['text'],
                          initialImage: notes[index]['image'] != null
                              ? File(notes[index]['image'])
                              : null,
                          onNoteUpdated: (updatedText, updatedImage) {
                            _updateNote(index, updatedText, updatedImage);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewNotePage(onNoteAdded: _addNewNote),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteNoteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notu Sil'),
          content: Text('Bu notu silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(index);
                Navigator.of(context).pop();
              },
              child: Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
