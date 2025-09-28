import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplitPage extends StatefulWidget {
  const SplitPage({super.key});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  List<TextEditingController> _nameControllers = [];
  List<String> _results = [];

  /// Generate dynamic name fields
  void _generateNameFields() {
    int people = int.tryParse(_peopleController.text) ?? 0;
    _nameControllers = List.generate(people, (_) => TextEditingController());
    _results = [];
    setState(() {});
  }

  /// Split equally among all members
  void _splitEqually() {
    double total = double.tryParse(_totalController.text) ?? 0.0;
    int people = _nameControllers.length;

    if (people > 0) {
      double share = total / people;
      _results = [];

      for (int i = 0; i < people; i++) {
        String name = _nameControllers[i].text.isNotEmpty
            ? _nameControllers[i].text
            : "Person ${i + 1}";
        _results.add("$name → ₹${share.toStringAsFixed(2)}");
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Bill"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Total bill
              TextField(
                controller: _totalController,
                decoration: const InputDecoration(
                  labelText: "Total Bill Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
              ),
              const SizedBox(height: 12),

              // Number of people
              TextField(
                controller: _peopleController,
                decoration: const InputDecoration(
                  labelText: "Number of People",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _generateNameFields(),
              ),
              const SizedBox(height: 12),

              // Dynamic name fields
              Column(
                children: List.generate(_nameControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: _nameControllers[index],
                      decoration: InputDecoration(
                        labelText: "Name ${index + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Split button
              ElevatedButton(
                onPressed: _splitEqually,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text("Split Equally"),
              ),
              const SizedBox(height: 20),

              // Results
              if (_results.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _results
                      .map((result) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                result,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
