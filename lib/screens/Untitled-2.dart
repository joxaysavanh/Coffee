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
  final String url = "http://192.168.3.169:3000/book"; // Keep using final
  bool _isLoading = true;
  String _errorMessage = '';
  // Make the controller final as it's initialized once
  final TextEditingController _searchController = TextEditingController();
  List _filteredData = [];

  @override
  void initState() {
    super.initState();
    fetchAllData();
    // Add listener for real-time filtering (optional but good UX)
    _searchController.addListener(() {
      _filterData(_searchController.text);
    });
  }

  // --- Add dispose method to clean up the controller ---
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // --- End dispose method ---

  Future<void> fetchAllData() async {
    // Prevent setting loading true if already loading from add/delete/update
    if (!_isLoading) {
       setState(() {
         _isLoading = true;
       });
    }
    setState(() {
      _errorMessage = ''; // Clear previous errors
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          // Apply filter immediately after fetching new data
          _filterData(_searchController.text);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}\nResponse: ${response.body}'; // Include response body
        });
         print('Failed Response Body (Fetch): ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
      print(e);
    }
  }

  // --- Function to handle data insertion via API POST request ---
  Future<void> _addData(Map<String, dynamic> newBook) async {
    setState(() {
      _isLoading = true; // Show loading indicator while adding
    });
    try {
      final response = await http.post(
        Uri.parse(url), // Use the same base URL for POST
        headers: <String, String>{
          // Important header for sending JSON data
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // Encode the new book map to a JSON string for the request body
        body: jsonEncode(newBook),
      );

      // 201 Created is standard for POST success, 200 OK might also be used
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Show success message BEFORE fetching for quicker feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ເພີ່ມຂໍ້ມູນສຳເລັດ!')), // Data added successfully!
        );
        // Refresh data to show the new item. fetchAllData handles the loading state.
        await fetchAllData(); // Use await to ensure fetch completes
      } else {
        // If adding failed, stop loading and show error
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ເພີ່ມຂໍ້ມູນບໍ່ສຳເລັດ. ລະຫັດ: ${response.statusCode}, ເຫດຜົນ: ${response.body}')), // Failed to add data. Code: ..., Reason: ...
        );
         print('Failed Response Body (Add): ${response.body}'); // Log the error response body
      }
    } catch (e) {
      // Handle potential network errors or other exceptions
      setState(() {
        _isLoading = false; // Stop loading indicator on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ມີຂໍ້ຜິດພາດເກີດຂຶ້ນ: $e')), // An error occurred
      );
      print('Error during addData: $e'); // Log the error
    }
  }
  // --- End _addData function ---


  // Function to handle data update (Placeholder - Needs API Implementation)
  void _updateData(int originalIndex, Map<String, dynamic> updatedBook) async {
     // --- Placeholder for PUT/PATCH Request ---
    final bookId = updatedBook['bookid'];
    final updateUrl = '$url/$bookId'; // Example URL structure

    print('Attempting to update book at original index: $originalIndex with ID: $bookId');
    print('Update URL: $updateUrl');
    print('Data to send: ${jsonEncode(updatedBook)}');

    // Example: Simulate success for UI update (Remove/replace with actual API call)
    setState(() {
       data[originalIndex] = updatedBook; // Update original data list
       _filterData(_searchController.text); // Re-apply filter to update _filteredData
    });
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('ແກ້ໄຂຂໍ້ມູນສຳເລັດ! (UI Only)')), // Indicate UI update only for now
     );

    /* --- Replace above simulation with actual API call ---
    setState(() { _isLoading = true; });
    try {
      final response = await http.put( // or http.patch
        Uri.parse(updateUrl),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(updatedBook),
      );

      if (response.statusCode == 200) { // Or appropriate success code for PUT/PATCH
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ແກ້ໄຂຂໍ້ມູນສຳເລັດ!')),
        );
        await fetchAllData(); // Refresh data from server
      } else {
         setState(() { _isLoading = false; });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('ແກ້ໄຂຂໍ້ມູນບໍ່ສຳເລັດ. ລະຫັດ: ${response.statusCode}, ເຫດຜົນ: ${response.body}')),
         );
         print('Failed Response Body (Update): ${response.body}');
      }
    } catch (e) {
       setState(() { _isLoading = false; });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('ມີຂໍ້ຜິດພາດຕອນອັບເດດ: $e')),
       );
       print('Error during updateData: $e');
    }
    */
    // --- End Placeholder ---
  }

  // Function to handle data deletion (Improved to handle filtered list index)
  void _deleteData(int filteredIndex) async {
    // Find the actual item in the original 'data' list based on the filtered list
    if (filteredIndex < 0 || filteredIndex >= _filteredData.length) return; // Index out of bounds check

    final bookToDelete = _filteredData[filteredIndex];
    final bookIdToDelete = bookToDelete['bookid'];

    // Find the index in the original data list (important if filtered)
    final originalIndex = data.indexWhere((item) => item['bookid'] == bookIdToDelete);
    if (originalIndex == -1) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error finding item to delete in original list.')),
       );
       print('Could not find book with ID $bookIdToDelete in original data list for deletion.');
       return; // Item not found in original list
    }

    final deleteUrl = '$url/$bookIdToDelete'; // Construct specific URL for DELETE
    setState(() { _isLoading = true; }); // Optional: show loading during delete

    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      // 204 No Content is also common for successful DELETE
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          // Remove from original data list first
          data.removeAt(originalIndex);
          // Then update the filtered list (which might be the same as removing at filteredIndex, but safer to refilter)
          _filterData(_searchController.text); // Re-apply filter to update UI correctly
          _isLoading = false; // Stop loading
        });
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ລຶບຂໍ້ມູນສຳເລັດ!')), // Data deleted successfully!
          );
      } else {
         setState(() { _isLoading = false; }); // Stop loading on failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ລຶບຂໍ້ມູນບໍ່ສຳເລັດ. ລະຫັດ: ${response.statusCode}, ເຫດຜົນ: ${response.body}')), // Failed to delete data
        );
         print('Failed Response Body (Delete): ${response.body}');
      }
    } catch (e) {
       setState(() { _isLoading = false; }); // Stop loading on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ມີຂໍ້ຜິດພາດຕອນລຶບຂໍ້ມູນ: $e')), // An error occurred while deleting
      );
      print('Error during deleteData: $e');
    }
  }

  // Function to filter data based on search text (Improved with null safety)
  void _filterData(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredData = List.from(data); // Show all if search is empty
      } else {
        _filteredData = data
            .where((item) {
              final bookNameLower = (item['bookname']?.toString() ?? '').toLowerCase();
              final bookIdLower = (item['bookid']?.toString() ?? '').toLowerCase();
              final searchLower = searchText.toLowerCase();
              return bookNameLower.contains(searchLower) || bookIdLower.contains(searchLower);
            })
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

  // --- Function to show a dialog for adding a new book ---
  Future<void> _showAddDialog(BuildContext context) async {
    // Use final for controllers within the function scope
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflict
        return AlertDialog(
          title: const Text('ເພີ່ມຂໍ້ມູນປຶ້ມໃໝ່'), // Add New Book Info
          content: SingleChildScrollView( // Use SingleChildScrollView for small screens
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(hintText: 'ປ້ອນລະຫັດປຶ້ມ'), // Enter Book ID
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'ປ້ອນຊື່ປຶ້ມ'), // Enter Book Name
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(hintText: 'ປ້ອນລາຄາ'), // Enter Price
                  keyboardType: TextInputType.numberWithOptions(decimal: true), // Suggest numeric keyboard
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ຍົກເລີກ', // Cancel
                // Use theme color for consistency
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext
              },
            ),
            TextButton(
              child: Text(
                'ເພີ່ມ', // Add
                // Use theme color for consistency
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                final String bookId = idController.text;
                final String bookName = nameController.text;
                final String price = priceController.text; // Keep as string for now

                if (bookId.isNotEmpty && bookName.isNotEmpty && price.isNotEmpty) {
                  // Basic validation: ensure fields are not empty
                  Map<String, dynamic> newBook = {
                    'bookid': bookId,
                    'bookname': bookName,
                    // Consider converting price if your API expects a number
                    // 'price': double.tryParse(price) ?? 0.0, // Example conversion
                    'price': price, // Sending as string based on current structure
                  };
                  // Call the function to send data to API
                  _addData(newBook); // _addData handles async and state updates
                  Navigator.of(dialogContext).pop(); // Close the dialog using dialogContext
                } else {
                  // Show error if fields are empty (using the main context's ScaffoldMessenger)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບຖ້ວນ')), // Please fill all fields
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- End _showAddDialog function ---


  // Function to show a dialog for editing book details (Improved)
  Future<void> _showEditDialog(
      BuildContext context, int filteredIndex, Map<String, dynamic> book) async {

     if (filteredIndex < 0 || filteredIndex >= _filteredData.length) return; // Index check

    // Find the index in the original data list
    final bookIdToEdit = book['bookid'];
    final originalIndex = data.indexWhere((item) => item['bookid'] == bookIdToEdit);
     if (originalIndex == -1) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error finding item to edit in original list.')),
       );
       print('Could not find book with ID $bookIdToEdit in original data list for editing.');
       return; // Item not found in original list
    }

    // Use current values from the book map, handle potential nulls
    final nameController = TextEditingController(text: book['bookname']?.toString() ?? '');
    final priceController = TextEditingController(text: book['price']?.toString() ?? '');
    final id = book['bookid']?.toString() ?? 'N/A'; // Display ID for reference

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ແກ້ໄຂຂໍ້ມູນປຶ້ມ (ID: $id)'), // Edit Book Info
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                 TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ຊື່ປຶ້ມ'), // Book Name
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'ລາຄາ'), // Price
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ຍົກເລີກ', // Cancel
                 style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'ອັບເດດ', // Update
                 style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                final updatedName = nameController.text;
                final updatedPrice = priceController.text;

                if (updatedName.isNotEmpty && updatedPrice.isNotEmpty) {
                  Map<String, dynamic> updatedBook = {
                    ...book, // Keep original ID and any other fields
                    'bookname': updatedName,
                    // Consider converting price if API expects number
                    // 'price': double.tryParse(updatedPrice) ?? book['price'],
                     'price': updatedPrice, // Sending as string
                  };
                  // Call the actual update function, passing the ORIGINAL index
                  _updateData(originalIndex, updatedBook);
                  Navigator.of(dialogContext).pop();
                  // Success message should be shown inside _updateData after successful API call
                } else {
                  // Show error within the dialog context if possible, or use main context
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ຊື່ ແລະ ລາຄາ ບໍ່ສາມາດວ່າງເປົ່າໄດ້')), // Name and Price cannot be empty
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Use theme colors for better adaptability
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // Use theme colors
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1, // Add slight elevation for separation
        title: const Text(
          'ລາຍການປຶ້ມ', // Book List (More appropriate title)
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Adjusted size
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65), // Slightly more height
          child: Padding( // Use Padding for better spacing control
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), // Consistent padding
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: "ຄົ້ນຫາດ້ວຍ ຊື່ ຫຼື ລະຫັດ...", // Search by Name or ID...
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  // Show clear button only when text exists
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.secondary),
                          tooltip: 'Clear Search', // Add tooltip
                          onPressed: _clearSearch,
                        )
                      : null,
                  isDense: true, // Make it more compact
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  // Use OutlineInputBorder for modern look
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                   focusedBorder: OutlineInputBorder( // Highlight when focused
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder( // Default border
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  // Removed filled/fillColor for a cleaner look, relying on border
                  ),
              // Listener handles filtering, no need for explicit search button press
              // onSubmitted: (value) => _filterData(value), // Optional: trigger on keyboard submit
            ),
          ),
        ),
      ),
      // Use RefreshIndicator for pull-to-refresh
      body: RefreshIndicator(
        onRefresh: fetchAllData,
        child: _isLoading && data.isEmpty // Show loading only on initial load or if data is empty
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center( // Improved error display
                   child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(Icons.error_outline, color: Colors.red, size: 40),
                         SizedBox(height: 10),
                         Text(_errorMessage, textAlign: TextAlign.center),
                         SizedBox(height: 10),
                         ElevatedButton(
                           onPressed: fetchAllData, // Retry button
                           child: Text('ລອງໃໝ່'), // Retry
                         )
                       ],
                     ),
                   )
                  )
                : _filteredData.isEmpty
                    // Show different message based on whether search is active
                    ? Center(child: Text( _searchController.text.isEmpty ? 'ບໍ່ມີຂໍ້ມູນປຶ້ມ' : 'ບໍ່ພົບຂໍ້ມູນທີ່ຄົ້ນຫາ')) // No books / No results found
                    : ListView.builder(
                        // Add padding at the bottom so FAB doesn't overlap last item
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) { // Use context instead of content
                          final book = _filteredData[index];
                          // Use ListTile inside Card for standard layout
                          return Card(
                             elevation: 2,
                             margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                             child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                // Leading avatar showing book ID
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text(
                                    book['bookid']?.toString() ?? '?', // Handle null ID
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer
                                    ),
                                  ),
                                ),
                                title: Text(
                                  book['bookname']?.toString() ?? 'Unknown Name', // Handle null name
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'ລາຄາ: ${book['price']?.toString() ?? 'N/A'}', // Handle null price
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                // Trailing icons for actions
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min, // Keep row compact
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: colorScheme.secondary),
                                      tooltip: 'ແກ້ໄຂ', // Edit
                                      onPressed: () {
                                        // Pass the filtered index and the book data
                                        _showEditDialog(context, index, book);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'ລຶບ', // Delete
                                      // Pass the filtered index to delete function
                                      onPressed: () => _deleteData(index),
                                    ),
                                  ],
                                ),
                             ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use theme colors
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        // --- Call _showAddDialog on pressed ---
        onPressed: () {
           _showAddDialog(context);
        },
        // --- End onPressed modification ---
        tooltip: 'ເພີ່ມປຶ້ມໃໝ່', // Add New Book
        child: const Icon(Icons.add),
      ),
    );
  }
}
