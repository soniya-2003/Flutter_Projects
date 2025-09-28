import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Bill input controllers
  final TextEditingController customTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();

  String selectedCategory = "Trip";
  List<Map<String, String>> savedBills = [];

  // Users fetched from JSONPlaceholder
  List<Map<String, dynamic>> users = [];
  bool isLoadingUsers = false;

  // Save bill function
  void saveBill() {
    final String customTitle = customTitleController.text.trim();
    final double? amount = double.tryParse(amountController.text);
    final int? people = int.tryParse(peopleController.text);

    if ((customTitle.isEmpty && selectedCategory == "Others") ||
        amount == null ||
        people == null ||
        people <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }

    final title = selectedCategory != "Others" ? selectedCategory : customTitle;
    final double perPerson = amount / people;

    setState(() {
      savedBills.add({
        "title": title,
        "amount": amount.toStringAsFixed(2),
        "people": people.toString(),
        "perPerson": perPerson.toStringAsFixed(2),
      });

      customTitleController.clear();
      amountController.clear();
      peopleController.clear();
      selectedCategory = "Trip";
    });
  }

  // Fetch dummy users from JSONPlaceholder
  Future<void> fetchUsers() async {
    setState(() => isLoadingUsers = true);

    try {
      final response =
          await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> usersData = jsonDecode(response.body);

        setState(() {
          users = usersData.map((user) {
            return {
              "name": user['name'] ?? '',
              "email": user['email'] ?? '',
            };
          }).toList();
          isLoadingUsers = false;
        });

        print("Fetched ${users.length} users");
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      setState(() => isLoadingUsers = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("QuickSplit"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Bill category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ["Trip", "Restaurant", "Movies", "Others"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Bill Category",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (selectedCategory == "Others")
                _buildTextField(customTitleController, "Enter Custom Title"),
              const SizedBox(height: 12),
              _buildTextField(amountController, "Total Amount", isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(peopleController, "Number of People",
                  isNumber: true),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveBill,
                child: const Text("Save Bill", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              
              // Fetch users button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: fetchUsers,
                child: const Text("Fetch Users",
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),

              // Saved bills
              if (savedBills.isNotEmpty)
                Column(
                  children: savedBills
                      .map((bill) => Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                bill["title"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "Total: ₹${bill["amount"]} | People: ${bill["people"]}\nEach: ₹${bill["perPerson"]}"),
                            ),
                          ))
                      .toList(),
                ),

              // Users from JSONPlaceholder
              if (isLoadingUsers) const CircularProgressIndicator(),
              if (users.isNotEmpty)
                Column(
                  children: users.map((user) {
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(user['name'].toString()),
                        subtitle: Text(user['email'].toString()),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
