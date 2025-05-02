import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage1 extends StatefulWidget {
  const ProductPage1({super.key});

  @override
  State<ProductPage1> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage1> {
  List<dynamic> data = [];
  List<dynamic> sizes = [];
  List<dynamic> categories = [];
  final String url = "http://192.168.114.192:3000/book"; // API endpoint
  final String sizesUrl = "http://192.168.114.192:3000/sizes"; // Sizes endpoint
  final String categoriesUrl =
      "http://192.168.114.192:3000/categories"; // Categories endpoint
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredData = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchAllData();
    fetchSizesAndCategories();
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

  Future<void> fetchSizesAndCategories() async {
    try {
      final sizesResponse = await http.get(Uri.parse(sizesUrl));
      final categoriesResponse = await http.get(Uri.parse(categoriesUrl));

      if (sizesResponse.statusCode == 200 &&
          categoriesResponse.statusCode == 200) {
        setState(() {
          sizes = json.decode(sizesResponse.body);
          categories = json.decode(categoriesResponse.body);
        });
      } else {
        print('Failed to load sizes or categories');
      }
    } catch (e) {
      print('Error fetching sizes or categories: $e');
    }
  }

  // Function to handle data update
  Future<void> _updateData(
      int index, Map<String, dynamic> updatedProduct) async {
    final productIdToUpdate = updatedProduct['Pro_ID'];
    final updateUrl = '$url/$productIdToUpdate';

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProduct),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update the data in both original and filtered lists
          if (data.isNotEmpty &&
              data.any((item) => item['Pro_ID'] == productIdToUpdate)) {
            final originalIndex =
                data.indexWhere((item) => item['Pro_ID'] == productIdToUpdate);
            data[originalIndex] = updatedProduct;
          }

          // Update in filtered list
          final filteredIndex = _filteredData
              .indexWhere((item) => item['Pro_ID'] == productIdToUpdate);
          if (filteredIndex != -1) {
            _filteredData[filteredIndex] = updatedProduct;
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
  Future<void> _addData(Map<String, dynamic> newProduct) async {
    try {
      print('Sending product data: $newProduct');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newProduct),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> createdProduct;

        if (response.body.isNotEmpty) {
          try {
            createdProduct = json.decode(response.body);
            print('Decoded response: $createdProduct');
          } catch (e) {
            print('Error decoding response: $e');
            createdProduct = newProduct;
          }
        } else {
          print('Empty response, using original product data');
          createdProduct = newProduct;
        }

        // Verify all product properties are present
        if (!createdProduct.containsKey('Pro_ID') ||
            !createdProduct.containsKey('Pro_Name') ||
            !createdProduct.containsKey('Pro_Price') ||
            !createdProduct.containsKey('Pro_Qty')) {
          print('Warning: Product data is missing some properties');
          // Ensure all fields exist
          createdProduct = {
            'Pro_ID': createdProduct['Pro_ID'] ?? newProduct['Pro_ID'],
            'Pro_Name': createdProduct['Pro_Name'] ?? newProduct['Pro_Name'],
            'Pro_Price': createdProduct['Pro_Price'] ?? newProduct['Pro_Price'],
            'Pro_Qty': createdProduct['Pro_Qty'] ?? newProduct['Pro_Qty'],
            'Pro_Descrip':
                createdProduct['Pro_Descrip'] ?? newProduct['Pro_Descrip'],
            'Size_ID': createdProduct['Size_ID'] ?? newProduct['Size_ID'],
            'Cg_ID': createdProduct['Cg_ID'] ?? newProduct['Cg_ID'],
          };
        }

        setState(() {
          data.add(createdProduct);
          _filterData(_searchController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ເພີ່ມຂໍ້ມູນສຳເລັດ!')),
          );
        });
      } else {
        print('Failed to add product. Status code: ${response.statusCode}');
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
    final productIdToDelete = _filteredData[index]['Pro_ID'];
    final deleteUrl = '$url/$productIdToDelete';

    // Show confirmation dialog
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    if (!confirmDelete) return;

    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        setState(() {
          // Remove from original data list
          data.removeWhere((item) => item['Pro_ID'] == productIdToDelete);
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
              actions: [
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
                  child: const Text(
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
                item['Pro_Name']
                    .toString()
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                item['Pro_ID']
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
                  Icons.shopping_bag_rounded,
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
                          final product = _filteredData[index];
                          // Find size and category names
                          String sizeName = sizes.firstWhere(
                            (size) => size['Size_ID'] == product['Size_ID'],
                            orElse: () => {'Size_Name': 'N/A'},
                          )['Size_Name'];

                          String categoryName = categories.firstWhere(
                            (category) => category['Cg_ID'] == product['Cg_ID'],
                            orElse: () => {'Cg_Name': 'N/A'},
                          )['Cg_Name'];

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
                                      'ລະຫັດ: ${product['Pro_ID']}',
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
                                          'ຊື່: ${product['Pro_Name']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'ລາຄາ: ${product['Pro_Price']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'ຈຳນວນ: ${product['Pro_Qty']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (product['Pro_Descrip'] != null)
                                          Text(
                                            'ລາຍລະອຽດ: ${product['Pro_Descrip']}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        Text(
                                          'ຂະໜາດ: $sizeName',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'ໝວດ: $categoryName',
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
                                          color: Colors.blue,
                                          tooltip: 'ແກ້ໄຂ',
                                          onPressed: () {
                                            _showEditDialog(
                                                context, index, product);
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
        tooltip: 'ເພີ່ມສິນຄ້າໃໝ່',
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Function to show a dialog for editing product fields
  Future<void> _showEditDialog(
      BuildContext context, int index, Map<String, dynamic> product) async {
    TextEditingController nameController =
        TextEditingController(text: product['Pro_Name'].toString());
    TextEditingController priceController =
        TextEditingController(text: product['Pro_Price'].toString());
    TextEditingController qtyController =
        TextEditingController(text: product['Pro_Qty'].toString());
    TextEditingController descriptionController =
        TextEditingController(text: product['Pro_Descrip']?.toString() ?? '');

    // Current selected size and category
    String? selectedSizeId = product['Size_ID']?.toString();
    String? selectedCategoryId = product['Cg_ID']?.toString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ແກ້ໄຂຂໍ້ມູນສິນຄ້າ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ລະຫັດສິນຄ້າ: ${product['Pro_ID']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ຊື່ສິນຄ້າ',
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
                  controller: qtyController,
                  decoration: const InputDecoration(
                    labelText: 'ຈຳນວນ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'ລາຍລະອຽດ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSizeId,
                  decoration: const InputDecoration(
                    labelText: 'ຂະໜາດ',
                    border: OutlineInputBorder(),
                  ),
                  items: sizes.map<DropdownMenuItem<String>>((size) {
                    return DropdownMenuItem<String>(
                      value: size['Size_ID'].toString(),
                      child: Text(size['Size_Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedSizeId = value;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'ໝວດ',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category['Cg_ID'].toString(),
                      child: Text(category['Cg_Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                  },
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
                final updatedQty = int.tryParse(qtyController.text) ?? 0;
                final updatedDescription = descriptionController.text;
                final updatedSizeId = int.tryParse(selectedSizeId ?? '0') ?? 0;
                final updatedCgId =
                    int.tryParse(selectedCategoryId ?? '0') ?? 0;

                if (updatedName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ຊື່ສິນຄ້າບໍ່ສາມາດວ່າງເປົ່າໄດ້')),
                  );
                  return;
                }

                Map<String, dynamic> updatedProduct = {
                  ...product,
                  'Pro_Name': updatedName,
                  'Pro_Price': updatedPrice,
                  'Pro_Qty': updatedQty,
                  'Pro_Descrip': updatedDescription,
                  'Size_ID': updatedSizeId,
                  'Cg_ID': updatedCgId,
                };

                _updateData(index, updatedProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for adding a new product
  Future<void> _showAddDialog(BuildContext context) async {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController qtyController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedSizeId;
    String? selectedCategoryId;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ເພີ່ມສິນຄ້າໃໝ່'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'ລະຫັດສິນຄ້າ',
                    border: OutlineInputBorder(),
                    hintText: 'ຕົວຢ່າງ: P001',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ຊື່ສິນຄ້າ',
                    border: OutlineInputBorder(),
                    hintText: 'ກະລຸນາປ້ອນຊື່ສິນຄ້າ',
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
                  controller: qtyController,
                  decoration: const InputDecoration(
                    labelText: 'ຈຳນວນ',
                    border: OutlineInputBorder(),
                    hintText: '0',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'ລາຍລະອຽດ',
                    border: OutlineInputBorder(),
                    hintText: 'ກະລຸນາປ້ອນລາຍລະອຽດ',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSizeId,
                  decoration: const InputDecoration(
                    labelText: 'ຂະໜາດ',
                    border: OutlineInputBorder(),
                  ),
                  items: sizes.map<DropdownMenuItem<String>>((size) {
                    return DropdownMenuItem<String>(
                      value: size['Size_ID'].toString(),
                      child: Text(size['Size_Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedSizeId = value;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'ໝວດ',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category['Cg_ID'].toString(),
                      child: Text(category['Cg_Name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                  },
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
                final proId = idController.text.trim();
                final proName = nameController.text.trim();
                final proPrice = int.tryParse(priceController.text) ?? 0;
                final proQty = int.tryParse(qtyController.text) ?? 0;
                final proDescription = descriptionController.text.trim();
                final proSizeId = int.tryParse(selectedSizeId ?? '0') ?? 0;
                final proCgId = int.tryParse(selectedCategoryId ?? '0') ?? 0;

                if (proId.isEmpty || proName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'ລະຫັດສິນຄ້າ ແລະ ຊື່ສິນຄ້າບໍ່ສາມາດວ່າງເປົ່າໄດ້')),
                  );
                  return;
                }

                // Check if product ID already exists
                if (data.any((item) => item['Pro_ID'] == proId)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ລະຫັດສິນຄ້ານີ້ມີໃນລະບົບແລ້ວ')),
                  );
                  return;
                }

                final newProduct = {
                  'Pro_ID': proId,
                  'Pro_Name': proName,
                  'Pro_Price': proPrice,
                  'Pro_Qty': proQty,
                  'Pro_Descrip': proDescription,
                  'Size_ID': proSizeId,
                  'Cg_ID': proCgId,
                };

                _addData(newProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
