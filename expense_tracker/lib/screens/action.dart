import 'package:expense_tracker/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _Action();
}

class _Action extends State<ActionPage> {
  DateTime? selectedDate; // Declare a variable to store the selected date
  TextEditingController expenseController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  int? expenseAmount;
  late Expense expense;
  final categoryController = TextEditingController();
  final List<String> yourCategories = [
    'Food',
    'Travel',
    'Health',
    'Insurance',
    'Credit',
    'Rent',
    'Interest',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Add Expense",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: expenseController,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      hintText: "Enter the value",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: const Icon(
                        FontAwesomeIcons.dollarSign,
                        size: 16,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // Capture text input and convert to integer
                      try {
                        expenseAmount = int.parse(value);
                      } on FormatException {
                        // Handle parsing error (e.g., show a warning to the user)
                        print('Invalid input: Please enter a number.');
                        expenseAmount = null; // Reset to null if parsing fails
                      }
                    },
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: categoryController,
                  textAlignVertical: TextAlignVertical.center,
                  readOnly: true,
                  onTap: () {
                    CategoryDropdown(
                      controller: categoryController,
                      categories: yourCategories,
                      onSelected: (selectedCategory) {
                        // Handle category selection here (e.g., navigate to a new screen, perform actions)
                        print('Selected category: $selectedCategory');
                      },
                    );
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Category',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  //date
                  textAlignVertical: TextAlignVertical.center,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(
                      FontAwesomeIcons.clock,
                      size: 16,
                      color: Colors.grey,
                    ),
                    hintText: 'Date',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  initialValue: selectedDate != null
                      ? DateTime(TimeOfDay.hoursPerPeriod).timeZoneName
                      : null, // Display placeholder if no date selected
                ),
                const SizedBox(
                  height: 30,
                ), // Added spacing below the date field

                ElevatedButton(
                  onPressed: () async {
                    final String value = expenseController.text.trim();
                    int? integerValue = int.tryParse(value);
                    if (value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the value')),
                      );
                      return;
                    }
                    if (integerValue == null) {
                      ErrorHint("Value is not a number");
                      return;
                    }

                    try {
                      final String expenseId =
                          expensesdb.push().key!; // Generate unique ID
                      // Set the value of the new child node with expense data and unique ID

                      await expensesdb.child(expenseId).set({
                        "value": expenseAmount, // Expense value
                      });
                      expenseController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Expense added successfully!')),
                      );
                      // Show a success message (optional)
                    } on FirebaseException catch (e) {
                      // Handle potential errors during data writing
                      print(e.message); // Log the error for debugging
                      // Show an error message to the user
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: context.read<DateProvider>().selectedDate ??
          DateTime.now(), // Use selectedDate if available, otherwise use today
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2040, 12, 31),
    );
    if (pickedDate != null &&
        pickedDate != context.read<DateProvider>().selectedDate) {
      context.read<DateProvider>().selectedDate = pickedDate;
      print(context.read<DateProvider>().selectedDate);
    }
  }
}

class DateProvider extends ChangeNotifier {
  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;

  set selectedDate(DateTime? value) {
    _selectedDate = value;
    notifyListeners();
  }
}

class CategoryDropdown extends StatelessWidget {
  final TextEditingController controller;
  final List<String> categories; // List of available category options
  final void Function(String) onSelected; // Callback for handling selection

  const CategoryDropdown({
    super.key,
    required this.controller,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty
          ? null
          : controller.text, // Pre-select based on controller text
      items: categories
          .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (value) {
        controller.text = value ?? ''; // Update controller value
        onSelected(value ?? ''); // Call callback with selected value
      },
      decoration: const InputDecoration(
        filled: true,
        hintText: 'Category',
      ),
    );
  }
}

class Expense {
  String expenseId;
  Category category;
  DateTime date;
  int amount;

  Expense({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
  });

  static final empty = Expense(
    expenseId: '',
    category: Category.empty,
    date: DateTime.now(),
    amount: 0,
  );
}

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
  });

  static final empty =
      Category(categoryId: '', name: '', totalExpenses: 0, icon: '', color: 0);
}
