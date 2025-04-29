import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage1 extends StatefulWidget {
  const ProductPage1({super.key});

  @override
  State<ProductPage1> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage1> {
  List data = [];
  final String url = "http://192.168.3.169:3000/book";
  bool _isLoading = true;
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();
  List _filteredData = [];

  @override
  void initState() {
    super.initState();
    fetchAllData();
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
      print(e);
    }
  }

  // Function to handle data update (you need to implement the API call)
  void _updateData(int index, Map<String, dynamic> updatedBook) {
    print('ແກ້ໄຂຂໍ້ມູນທີ່: $index with: $updatedBook');
  }

  // Function to handle data deletion (you need to implement the API call)
  void _deleteData(int index) async {
    final bookIdToDelete = data[index]['bookid'];
    final deleteUrl = '$url/$bookIdToDelete';
    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        setState(() {
          data.removeAt(index);
          _filteredData.removeWhere((item) => item['bookid'] == bookIdToDelete);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data deleted successfully!')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete data. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting: $e')),
      );
      print(e);
    }
  }

  // Function to filter data based on search text
  void _filterData(String searchText) {
    setState(() {
      _filteredData = data
          .where((item) =>
              item['bookname']
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              item['bookid'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
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
                  prefix: Icon(
                    Icons.book_rounded,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  labelText: "ຂໍ້ມູນທີ່ຕ້ອງການຄົ້ນຫາ",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                  )),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (content, index) {
                          final book = _filteredData[index];
                          return Card(
                            // ห่อด้วย Card เพื่อให้ดูเป็นก้อน
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Padding(
                              // เพิ่ม Padding ภายใน Card เพื่อให้ข้อมูลไม่ชิดขอบ
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                // จัดเรียงข้อมูลในแนวนอน
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
                                      // จัดเรียงชื่อและราคาในแนวตั้ง
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
                                        Text(
                                          'ລາຄາ: ${book['price']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
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
                                          onPressed: () {
                                            // Implement your edit functionality here
                                            // You might want to show a dialog or navigate to an edit screen
                                            print(
                                                'Edit button pressed for index: $index');
                                            // Example of showing a simple dialog for editing name
                                            _showEditDialog(
                                                context, index, book);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
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
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Theme.of(context).colorScheme.background, // วงกลมเป็นสีม่วงอยู่แล้ว
        onPressed: () {},
        child: Icon(
          Icons.add,
          color: Theme.of(context)
              .colorScheme
              .primary, // กำหนดให้ไอคอน + เป็นสีขาว
        ),
      ),
    );
  }

  // Function to show a dialog for editing book name
  Future<void> _showEditDialog(
      BuildContext context, int index, Map<String, dynamic> book) async {
    TextEditingController nameController =
        TextEditingController(text: book['bookname']);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ປ່ຽນຊື່ປຶ້ມ'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'ປ້ອມຊື່ປຶ້ມ'),
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
                if (updatedName.isNotEmpty) {
                  Map<String, dynamic> updatedBook = {
                    ...book,
                    'bookname': updatedName
                  };
                  _updateData(index, updatedBook); // Call update function
                  setState(() {
                    _filteredData[index]['bookname'] =
                        updatedName; // Update local list
                    if (data.isNotEmpty &&
                        data.any((item) => item['bookid'] == book['bookid'])) {
                      final originalIndex = data.indexWhere(
                          (item) => item['bookid'] == book['bookid']);
                      data[originalIndex]['bookname'] = updatedName;
                    }
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ແກ້ໄຂຊື່ປຶ້ມສຳເລັດ!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ບໍ່ສາມາດວ່າງເປົ່າໄດ້')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}