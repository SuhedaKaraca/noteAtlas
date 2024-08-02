import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditNotePage extends StatefulWidget {
  final String initialText;
  final File? initialImage;
  final Function(String, File?) onNoteUpdated;

  EditNotePage(
      {required this.initialText,
      required this.initialImage,
      required this.onNoteUpdated});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _noteController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialText);
    _image = widget.initialImage;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notu Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Notunuz'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : Text('Görsel eklenmedi.'),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Görsel Değiştir'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onNoteUpdated(_noteController.text, _image);
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
