import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewNotePage extends StatefulWidget {
  final Function(String, File?) onNoteAdded;

  NewNotePage({required this.onNoteAdded});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final TextEditingController _noteController = TextEditingController();
  File? _image;

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
        title: Text('Yeni Not'),
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
              child: Text('Görsel Ekle'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onNoteAdded(_noteController.text, _image);
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
