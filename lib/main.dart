import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Credit Card Info Note',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tambahanController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      _tambahanController.text = existingJournal['tambahan'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Nomor Kartu'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Tanggal Kadaluarsa'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _tambahanController,
                    decoration: const InputDecoration(hintText: 'CCV'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _descriptionController.text = '';
                      _tambahanController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Tambah' : 'Perbarui'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text, _tambahanController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text, _tambahanController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Informasi dihapus'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Info Note'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),

            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.all(15),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text('Nomor Kartu',
                            style: TextStyle(fontWeight: FontWeight.bold)),),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text(_journals[index]['title']),),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text('Tanggal Kadaluarsa',
                            style: TextStyle(fontWeight: FontWeight.bold)),),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text(_journals[index]['description']),),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text('CVV',
                            style: TextStyle(fontWeight: FontWeight.bold)),),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                        child: Text(_journals[index]['tambahan']),),

                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(90, 0, 0, 0),
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_journals[index]['id']),
                        ),),
                      ],
                ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteItem(_journals[index]['id']),
                    ),
                  ],
                ),

              ),


        ),


      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text('CCID'),
            ),
            ListTile(
              title: const Text('Tips'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
      ),
      body: Center(
        child: WebView(
          initialUrl: 'https://tekno.sindonews.com/read/625491/123/7-tips-penting-menyimpan-data-dan-informasi-pribadi-secara-aman-1639221125',
          zoomEnabled: true,
          gestureNavigationEnabled: true,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }}
