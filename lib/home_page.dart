import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'note_type_page.dart';
import 'welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> noteTypes = [
    {
      'title': 'Günlük Planlama',
      'image': 'assets/images/daily_planning.png',
      'count': 0
    },
    {
      'title': 'Market Alışverişi',
      'image': 'assets/images/shopping.png',
      'count': 0
    },
    {
      'title': 'Yapılacaklar',
      'image': 'assets/images/todo_list.png',
      'count': 0
    },
    {
      'title': 'Kişisel Notlar',
      'image': 'assets/images/personal_notes.png',
      'count': 0
    },
    {
      'title': 'İş Notları',
      'image': 'assets/images/work_notes.png',
      'count': 0
    },
    {
      'title': 'Seyahat Notları',
      'image': 'assets/images/travel_notes.png',
      'count': 0
    },
    {
      'title': 'Eğitim Notları',
      'image': 'assets/images/education_notes.png',
      'count': 0
    },
    {
      'title': 'Diğer Notlar',
      'image': 'assets/images/other_notes.png',
      'count': 0
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNoteCounts();
  }

  void _loadNoteCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var noteType in noteTypes) {
      int count = prefs.getInt(noteType['title']) ?? 0;
      noteType['count'] = count;
    }
    setState(() {});
  }

  void _addNewNoteType(String title, File imageFile) {
    setState(() {
      noteTypes.add({'title': title, 'image': imageFile.path, 'count': 0});
    });
  }

  void _updateNoteCount(String noteType, int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(noteType, count);
    setState(() {
      final index = noteTypes.indexWhere((type) => type['title'] == noteType);
      if (index != -1) {
        noteTypes[index]['count'] = count;
      }
    });
  }

  Future<void> _showAddNoteTypeDialog() async {
    final TextEditingController _titleController = TextEditingController();
    File? _imageFile;
    bool _imageSelected = true;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Yeni Tür Ekle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Başlık'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _imageFile = File(pickedFile.path);
                          _imageSelected = true;
                        });
                      }
                    },
                    child: Text('Görsel Seç'),
                  ),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Text(
                          'Görsel seçilmedi.',
                          style: TextStyle(
                              color:
                                  _imageSelected ? Colors.black : Colors.red),
                        ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _imageFile != null) {
                      _addNewNoteType(_titleController.text, _imageFile!);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        if (_imageFile == null) {
                          _imageSelected = false;
                        }
                      });
                    }
                  },
                  child: Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NoteAtlas'),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Çıkış Yap'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: noteTypes.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteTypePage(
                          noteType: noteTypes[index]['title']!,
                          onNoteCountChanged: (count) {
                            _updateNoteCount(noteTypes[index]['title']!, count);
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15.0)),
                            child: Image.asset(
                              noteTypes[index]['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            noteTypes[index]['title']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      noteTypes[index]['count'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteTypeDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
