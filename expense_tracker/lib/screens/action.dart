// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:expense_tracker/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _Action();
}

class _Action extends State<ActionPage> {
  late FocusNode _focusNode;
  DateTime? selectedDate;
  TextEditingController expenseController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  double? expenseAmount;

  get selectCategory => CategoryProvider();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
                _buildInput(),
                const SizedBox(
                  height: 32,
                ),
                _buildCategory(context),
                const SizedBox(
                  height: 30,
                ),
                _buildDescription(),
                const SizedBox(
                  height: 30,
                ),
                _buildDate(),
                const SizedBox(
                  height: 30,
                ),
                _buildSave(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextFormField(
        focusNode: _focusNode,
        controller: expenseController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
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
          // Capture text input and convert to double
          try {
            expenseAmount = double.parse(value);
          } on FormatException {
            // Handle parsing error (e.g., show a warning to the user)
            const Text('Invalid input: Please enter a valid number.');
            expenseAmount = null; // Reset to null if parsing fails
          }
        },
      ),
    );
  }

  Widget _buildCategory(BuildContext context) {
    return Consumer<CategoryProvider>(builder: (context, provider, child) {
      String firstCategoryName =
          provider.categories.isNotEmpty ? provider.categories.first.name : '';

      String selectedCategoryName = provider.selectedCategory?.name ?? '';
      String hintText = 'Select Category (e.g. $firstCategoryName)';

      // If no category is selected, default to the first category
      if (selectedCategoryName.isEmpty && provider.categories.isNotEmpty) {
        provider.selectCategory(provider.categories.first);
      }

      TextEditingController controller =
          TextEditingController(text: selectedCategoryName);

      return TextFormField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        readOnly: true,
        onTap: () => _showCategoryPicker(context, provider),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: hintText,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12), bottom: Radius.circular(12)),
              borderSide: BorderSide.none),
        ),
        style: TextStyle(
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    });
  }

  Widget _buildDescription() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      child: TextFormField(
        controller: descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Enter a description (optional)",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, CategoryProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select a Category'),
          actions:
              List<Widget>.generate(provider.categories.length, (int index) {
            return CupertinoActionSheetAction(
              child: Text(provider.categories[index].name),
              onPressed: () {
                if (provider.categories[index].name == 'Other >') {
                  Navigator.pop(context);
                  _showNewCategoryDialog(context, provider);
                } else {
                  provider.selectCategory(provider.categories[index]);
                  Navigator.pop(context);
                }
              },
            );
          }),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showNewCategoryDialog(BuildContext context, CategoryProvider provider) {
    TextEditingController newCategoryController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Add New Category'),
          content: CupertinoTextField(
            controller: newCategoryController,
            placeholder: 'Enter category name',
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Add'),
              onPressed: () {
                String newCategoryName = newCategoryController.text.trim();
                if (newCategoryName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Category name cannot be empty')),
                  );
                  return;
                }
                if (provider.categories.any((category) =>
                    category.name.toLowerCase() ==
                    newCategoryName.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category already exists')),
                  );
                  return;
                }

                provider.addCategory(Category(
                  categoryId: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newCategoryName,
                ));
                provider.selectCategory(provider.categories.last);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDate() {
    return Consumer<DateProvider>(builder: (context, dateProvider, child) {
      return TextFormField(
        // Date input field
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
          hintText: 'Select Date',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        controller: TextEditingController(
            text: dateProvider.selectedDate != null
                ? DateFormat('dd MMMM yyyy').format(dateProvider.selectedDate)
                : ''), // Using a controller to set text
      );
    });
  }

  Widget _buildSave(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final String value = expenseController.text.trim();
        final String description = descriptionController.text.trim();
        double? integerValue = double.tryParse(value);
        if (value.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter the value')),
          );
          return;
        }
        if (integerValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Value is not a number')),
          );
          return;
        }

        // Accessing the selected date and category from their providers
        final DateTime selectedDate =
            Provider.of<DateProvider>(context, listen: false).selectedDate;
        final Category? selectedCategory =
            Provider.of<CategoryProvider>(context, listen: false)
                .selectedCategory;

        if (selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')),
          );
          return;
        }

        // Formatting date for storage
        String formattedDate = selectedDate != null
            ? DateFormat('dd-MM-yyyy').format(selectedDate)
            : DateFormat('dd-MM-yyyy').format(DateTime.now());

        try {
          final String expenseId = expensesdb.push().key!; // Generate unique ID

          // Set the value of the new child node with expense data and unique ID
          await expensesdb.child(expenseId).set({
            "value": integerValue,
            "date": formattedDate,
            "category": selectedCategory.name,
            "description": description, // Add description to the database
          });

          expenseController.clear();
          descriptionController.clear(); // Clear description field
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
        } on FirebaseException catch (e) {
          // Handle potential errors during data writing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        } finally {
          // Re-enable the button after saving is completed
          setState(() {
            expenseController.clear();
            descriptionController.clear(); // Clear description field
          });
        }
      },
      child: const Text('Save'),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: context
          .read<DateProvider>()
          .selectedDate, // Use selectedDate if available, otherwise use today
      firstDate: DateTime(2024),
      lastDate: DateTime(2040),
    );
    if (pickedDate != null &&
        pickedDate != context.read<DateProvider>().selectedDate) {
      context.read<DateProvider>().selectedDate = pickedDate;
    }
  }
}

class Category {
  String categoryId;
  String name;

  Category({
    required this.categoryId,
    required this.name,
  });

  static final empty = Category(categoryId: '', name: '');
}

class CategoryProvider extends ChangeNotifier {
  List<Category> categories = [
    Category(
      categoryId: '1',
      name: 'Food',
    ),
    Category(
      categoryId: '2',
      name: 'Shopping',
    ),
    Category(
      categoryId: '3',
      name: 'Travel',
    ),
    Category(
      categoryId: '4',
      name: 'Health',
    ),
    Category(
      categoryId: '5',
      name: 'Insurance',
    ),
    Category(
      categoryId: '6',
      name: 'Credit',
    ),
    Category(
      categoryId: '7',
      name: 'Income',
    ),
    Category(
      categoryId: '8',
      name: 'Other >',
    ),
  ];

  Category? selectedCategory;

  void selectCategory(Category category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addCategory(Category category) {
    categories.add(category);
    notifyListeners();
  }
}

class DateProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now(); // Default to current date

  DateTime get selectedDate => _selectedDate;

  set selectedDate(DateTime value) {
    if (_selectedDate != value) {
      _selectedDate = value;
      notifyListeners();
    }
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
