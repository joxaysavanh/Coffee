import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category;
  final String? size;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.category,
    this.size,
    this.rating = 4.5,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['Pro_ID'] ?? 0,
      name: json['Pro_Name'] ?? '',
      price: (json['Pro_Price'] is int)
          ? (json['Pro_Price'] as int).toDouble()
          : json['Pro_Price']?.toDouble() ?? 0.0,
      quantity: json['Pro_Qty'] ?? 0,
      imageUrl: json['Pro_Image'],
      category: json['Cg_Name'],
      size: json['Size_Name'],
      rating: 4.5 +
          (json['Pro_ID'] % 5) /
              10, // Generate a rating between 4.5-4.9 for display purposes
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Show product details when tapped
            _showProductDetails(context, product);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Hero(
                tag: 'product-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCoffeePlaceholder();
                                },
                              )
                            : _buildCoffeePlaceholder(),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'with ${product.size ?? 'Regular'}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Add to cart functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${product.name} ເພີ່ມເຂົ້າກະຕ່າແລ້ວ'),
                                backgroundColor: Color(0xFFE67E22),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(0xFFE67E22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoffeePlaceholder() {
    final List<String> coffeeImages = [
      'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=500',
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=500',
      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=500',
      'https://images.unsplash.com/photo-1507133750040-4a8f57021571?q=80&w=500',
    ];

    // Use product ID to deterministically select an image
    final imageIndex = product.id % coffeeImages.length;

    return Image.network(
      coffeeImages[imageIndex],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.coffee, size: 50, color: Colors.grey[500]),
          ),
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button and favorite
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.black),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Toggle favorite
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ເພີ່ມເຂົ້າລາຍການທີ່ມັກແລ້ວ'),
                            backgroundColor: Color(0xFFE67E22),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_border, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Product image
              Hero(
                tag: 'product-${product.id}',
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildCoffeePlaceholder();
                                },
                              )
                            : _buildCoffeePlaceholder(),
                  ),
                ),
              ),

              // Product name and rating
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            product.category ?? 'Coffee',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Size options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          _buildSizeOption('S', 'Small', true),
                          _buildSizeOption('M', 'Medium', false),
                          _buildSizeOption('L', 'Large', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'ເຄື່ອງດື່ມລົດຊາດດີ ຄຸນນະພາບສູງ ຈາກແຫຼ່ງປູກກາເຟທີ່ມີຊື່ສຽງ. ຄວາມຂົມກໍາລັງດີ ມີຄວາມຫວານທໍາມະຊາດ ແລະກິ່ນຫອມເຂັ້ມຂຸ້ນ ເຮັດໃຫ້ທ່ານສົດຊື່ນຕະຫຼອດວັນ.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Customization section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildCustomizationOption(
                        'Sugar', ['No Sugar', '30%', '50%', '70%', '100%']),
                    SizedBox(height: 16),
                    _buildCustomizationOption('Ice',
                        ['No Ice', 'Less Ice', 'Regular Ice', 'Extra Ice']),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Price and add to cart
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${product.price.toStringAsFixed(0)}k',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE67E22),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${product.name} ເພີ່ມເຂົ້າກະຕ່າແລ້ວ'),
                              backgroundColor: Color(0xFFE67E22),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE67E22),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String size, String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Material(
        color: isSelected ? Color(0xFFE67E22) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '($label)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizationOption(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected =
                  index == 1; // Default second option as selected
              return Container(
                margin: EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(options[index]),
                  selected: isSelected,
                  onSelected: (_) {},
                  backgroundColor: Colors.grey[200],
                  selectedColor: Color(0xFFE67E22).withOpacity(0.2),
                  checkmarkColor: Color(0xFFE67E22),
                  labelStyle: TextStyle(
                    color: isSelected ? Color(0xFFE67E22) : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Main Widget Definition
class ShowProductsPage extends StatefulWidget {
  const ShowProductsPage({Key? key}) : super(key: key);

  @override
  State<ShowProductsPage> createState() => _ShowProductsPageState();
}

class _ShowProductsPageState extends State<ShowProductsPage> {
  List<Product> products = [];
  List<String> categories = [
    'All',
    'Cappuccino',
    'Latte',
    'Machiato',
    'Americano',
    'Espresso',
    'Mocha',
    'Flat White'
  ];
  String selectedCategory = 'All';
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  ScrollController _scrollController = ScrollController();
  ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();

    // Add listener to search controller
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });

    // Add scroll listeners for better UX
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // You can add animations or behavior based on scroll position
    setState(() {
      // This will trigger a rebuild to update any UI that depends on scroll position
    });
  }

  void _scrollToCategory(String category) {
    // Find the index of the category
    final index = categories.indexOf(category);
    if (index >= 0) {
      // Calculate the scroll position
      final scrollPosition = index * 80.0; // Approximate width of each category
      _categoryScrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.114.192:3000/book'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  List<Product> getFilteredProducts() {
    List<Product> result = products;

    // Filter by category if not "All"
    if (selectedCategory != 'All') {
      result = result
          .where((product) =>
              product.category == selectedCategory ||
              product.name
                  .toLowerCase()
                  .contains(selectedCategory.toLowerCase()))
          .toList();
    }

    // Filter by search query if not empty
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              (product.category?.toLowerCase().contains(query) ?? false) ||
              (product.size?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = getFilteredProducts();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with location and profile
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Color(0xFFE67E22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'West, Balurghat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'ຄົ້ນຫາເຄື່ອງດື່ມ',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 6),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE67E22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.tune, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories horizontal scrollable list
            Container(
              height: 60,
              color: Colors.white,
              child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFFE67E22) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFFE67E22)
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(0xFFE67E22).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content area with products
            Expanded(
              child: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFE67E22)))
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 60, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'ບໍ່ພົບຂໍ້ມູນ',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        selectedCategory = 'All';
                                      });
                                    },
                                    child: Text('ຄົ້ນຫາໃໝ່'),
                                  )
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchProducts,
                              color: Color(0xFFE67E22),
                              child: GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(16),
                                physics: BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return ProductCard(product: product);
                                },
                              ),
                            ),
            ),

            // Bottom navigation bar
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: Color(0xFFE67E22)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
