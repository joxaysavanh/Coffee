import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List data = [];
  final String url = "http://192.168.3.169:3000/book";
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List _filteredData = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          _filteredData = List.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
      print('Error fetching data: $e');
    }
  }

  // Function to handle data update
  Future<void> _updateData(int index, Map<String, dynamic> updatedBook) async {
    final bookIdToUpdate = updatedBook['bookid'];
    final updateUrl = '$url/$bookIdToUpdate';

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedBook),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update the data in both original and filtered lists
          if (data.isNotEmpty &&
              data.any((item) => item['bookid'] == bookIdToUpdate)) {
            final originalIndex =
                data.indexWhere((item) => item['bookid'] == bookIdToUpdate);
            data[originalIndex] = updatedBook;
          }

          // Update in filtered list
          final filteredIndex = _filteredData
              .indexWhere((item) => item['bookid'] == bookIdToUpdate);
          if (filteredIndex != -1) {
            _filteredData[filteredIndex] = updatedBook;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ຂໍ້ມູນຖືກອັບເດດສຳເລັດ!')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ການອັບເດດລົ້ມເຫຼວ. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')),
      );
      print('Error updating data: $e');
    }
  }

  // Function to add new data
  Future<void> _addData(Map<String, dynamic> newBook) async {
    try {
      print('Sending book data: $newBook'); // Debug the data being sent

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newBook),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> createdBook;

        if (response.body.isNotEmpty) {
          try {
            createdBook = json.decode(response.body);
            print('Decoded response: $createdBook');
          } catch (e) {
            print('Error decoding response: $e');
            createdBook = newBook;
          }
        } else {
          print('Empty response, using original book data');
          createdBook = newBook;
        }

        // Verify all book properties are present
        if (!createdBook.containsKey('bookid') ||
            !createdBook.containsKey('bookname') ||
            !createdBook.containsKey('price') ||
            !createdBook.containsKey('page')) {
          print('Warning: Book data is missing some properties');
          // Ensure all fields exist
          createdBook = {
            'bookid': createdBook['bookid'] ?? newBook['bookid'],
            'bookname': createdBook['bookname'] ?? newBook['bookname'],
            'price': createdBook['price'] ?? newBook['price'],
            'page': createdBook['page'] ?? newBook['page'],
          };
        }

        setState(() {
          data.add(createdBook);
          _filterData(_searchController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ເພີ່ມຂໍ້ມູນສຳເລັດ!')),
          );
        });
      } else {
        print('Failed to add book. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ການເພີ່ມຂໍ້ມູນລົ້ມເຫຼວ. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error in _addData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')),
      );
    }
  }

  // Function to handle data deletion
  Future<void> _deleteData(int index) async {
    final bookIdToDelete = _filteredData[index]['bookid'];
    final deleteUrl = '$url/$bookIdToDelete';

    // Show confirmation dialog
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    if (!confirmDelete) return;

    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        setState(() {
          // Remove from original data list
          data.removeWhere((item) => item['bookid'] == bookIdToDelete);
          // Remove from filtered list
          _filteredData.removeAt(index);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ລຶບຂໍ້ມູນສຳເລັດ!')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ການລຶບຂໍ້ມູນລົ້ມເຫຼວ. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດຂະນະລຶບຂໍ້ມູນ: $e')),
      );
      print('Error deleting data: $e');
    }
  }

  // Function to show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ຢືນຢັນການລຶບ'),
              content: const Text('ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບຂໍ້ມູນນີ້?'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'ຍົກເລີກ',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    'ລຶບ',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  // Function to filter data based on search text
  void _filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredData = List.from(data);
      } else {
        _filteredData = data
            .where((item) =>
                item['bookname']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                item['bookid']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  // Function to clear the search text
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredData = List.from(data); // Reset filtered data to all data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Setting Product Info Page',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(width: 1),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
                prefixIcon: Icon(
                  Icons.book_rounded,
                  color: Theme.of(context).colorScheme.background,
                ),
                labelText: "ຂໍ້ມູນທີ່ຕ້ອງການຄົ້ນຫາ",
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.background),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: _clearSearch,
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    IconButton(
                      onPressed: () => _filterData(_searchController.text),
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                _filterData(value);
              },
              style: TextStyle(color: Theme.of(context).colorScheme.background),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchAllData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _filteredData.isEmpty
                    ? const Center(child: Text('ບໍ່ພົບຂໍ້ມູນ'))
                    : ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          final book = _filteredData[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ລະຫັດ: ${book['bookid']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ຊື່: ${book['bookname']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'ລາຄາ: ${book['price']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'ຈຳນວນໜ້າ: ${book['page']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.blue,
                                          tooltip: 'ແກ້ໄຂ',
                                          onPressed: () {
                                            _showEditDialog(
                                                context, index, book);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          tooltip: 'ລຶບ',
                                          onPressed: () => _deleteData(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.background,
        onPressed: () {
          _showAddDialog(context);
        },
        tooltip: 'ເພີ່ມປຶ້ມໃໝ່',
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Function to show a dialog for editing all book fields
  Future<void> _showEditDialog(
      BuildContext context, int index, Map<String, dynamic> book) async {
    TextEditingController nameController =
        TextEditingController(text: book['bookname'].toString());
    TextEditingController priceController =
        TextEditingController(text: book['price'].toString());
    TextEditingController pageController =
        TextEditingController(text: book['page'].toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ແກ້ໄຂຂໍ້ມູນປຶ້ມ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ລະຫັດປຶ້ມ: ${book['bookid']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ຊື່ປຶ້ມ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ລາຄາ',
                    border: OutlineInputBorder(),
                    prefixText: '₭ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pageController,
                  decoration: const InputDecoration(
                    labelText: 'ຈຳນວນໜ້າ',
                    border: OutlineInputBorder(),
                    suffixText: 'ໜ້າ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ຍົກເລີກ',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'ອັບເດດ',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
              onPressed: () {
                final updatedName = nameController.text;
                final updatedPrice = int.tryParse(priceController.text) ?? 0;
                final updatedPage = int.tryParse(pageController.text) ?? 0;

                if (updatedName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ຊື່ປຶ້ມບໍ່ສາມາດວ່າງເປົ່າໄດ້')),
                  );
                  return;
                }

                Map<String, dynamic> updatedBook = {
                  ...book,
                  'bookname': updatedName,
                  'price': updatedPrice,
                  'page': updatedPage
                };

                _updateData(index, updatedBook);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for adding a new book
  Future<void> _showAddDialog(BuildContext context) async {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController pageController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ເພີ່ມປຶ້ມໃໝ່'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'ລະຫັດປຶ້ມ',
                    border: OutlineInputBorder(),
                    hintText: 'ຕົວຢ່າງ: BC13',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ຊື່ປຶ້ມ',
                    border: OutlineInputBorder(),
                    hintText: 'ກະລຸນາປ້ອນຊື່ປຶ້ມ',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ລາຄາ',
                    border: OutlineInputBorder(),
                    hintText: '0',
                    prefixText: '₭ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pageController,
                  decoration: const InputDecoration(
                    labelText: 'ຈຳນວນໜ້າ',
                    border: OutlineInputBorder(),
                    hintText: '0',
                    suffixText: 'ໜ້າ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ຍົກເລີກ',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'ເພີ່ມ',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
              onPressed: () {
                final bookId = idController.text.trim();
                final bookName = nameController.text.trim();
                final bookPrice = int.tryParse(priceController.text) ?? 0;
                final bookPage = int.tryParse(pageController.text) ?? 0;

                if (bookId.isEmpty || bookName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('ລະຫັດປຶ້ມ ແລະ ຊື່ປຶ້ມບໍ່ສາມາດວ່າງເປົ່າໄດ້')),
                  );
                  return;
                }

                // Check if book ID already exists
                if (data.any((item) => item['bookid'] == bookId)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ລະຫັດປຶ້ມນີ້ມີໃນລະບົບແລ້ວ')),
                  );
                  return;
                }

                final newBook = {
                  'bookid': bookId,
                  'bookname': bookName,
                  'price': bookPrice,
                  'page': bookPage
                };

                _addData(newBook);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
