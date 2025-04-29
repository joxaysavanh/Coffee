import 'package:flutter/material.dart';
import '../models/coffee_model.dart';
import '../widgets/coffee_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Dummy data for now, replace with data fetching
  final List<Coffee> _coffees = [
    Coffee(
      name: 'Cappuccino',
      description: 'Classic cappuccino with rich espresso and foamed milk.',
      imageUrl: 'https://via.placeholder.com/150/E0C2A8/FFFFFF?Text=Cappuccino1',
      price: 4.53,
      rating: 4.8,
      variations: ['with Chocolate'],
    ),
    Coffee(
      name: 'Cappuccino',
      description: 'Cappuccino with creamy oat milk.',
      imageUrl: 'https://via.placeholder.com/150/D2B48C/FFFFFF?Text=Cappuccino2',
      price: 3.90,
      rating: 4.9,
      variations: ['with Oat Milk'],
    ),
    Coffee(
      name: 'Cappuccino',
      description: 'Delicious cappuccino with chocolate drizzle.',
      imageUrl: 'https://via.placeholder.com/150/A0522D/FFFFFF?Text=Cappuccino3',
      price: 4.20,
      rating: 4.5,
      variations: ['with Chocolate'],
    ),
    Coffee(
      name: 'Cappuccino',
      description: 'Cappuccino made with organic oat milk.',
      imageUrl: 'https://via.placeholder.com/150/B8860B/FFFFFF?Text=Cappuccino4',
      price: 4.10,
      rating: 4.0,
      variations: ['with Oat Milk'],
    ),
    // Add more coffee items
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        // You can add actions here (e.g., search, cart)
      ),
      body: ListView.builder(
        itemCount: _coffees.length,
        itemBuilder: (context, index) {
          return CoffeeCard(coffee: _coffees[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0, // Set the initial index
        // You can add onTap functionality to navigate between different sections
      ),
    );
  }
}