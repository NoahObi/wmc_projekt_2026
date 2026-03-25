import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/localization_provider.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  const AddEditScreen({super.key, this.subscription});

  final Subscription? subscription;

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedBillingInterval = 'monthly';
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (widget.subscription != null) {
      _nameController.text = widget.subscription!.name;
      _priceController.text = widget.subscription!.price.toString();
      _descController.text = widget.subscription!.description;
      _selectedCategoryId = widget.subscription!.categoryId;
      _selectedBillingInterval = widget.subscription!.billingInterval;
      _selectedDate = widget.subscription!.startDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final language = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription != null
            ? AppLocalizations.translate(language, 'edit_subscription')
            : AppLocalizations.translate(language, 'new_subscription'),
          style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(AppLocalizations.translate(language, 'subscription_name')),
            _buildTextField(
              controller: _nameController,
              hintText: AppLocalizations.translate(language, 'subscription_name'),
            ),
            const SizedBox(height: 20),

            _buildLabel(AppLocalizations.translate(language, 'price')),
            _buildTextField(
              controller: _priceController,
              hintText: AppLocalizations.translate(language, 'price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            _buildLabel(AppLocalizations.translate(language, 'description_optional')),
            _buildTextField(
              controller: _descController,
              hintText: AppLocalizations.translate(language, 'description_optional'),
            ),
            const SizedBox(height: 25),

            _buildLabel(AppLocalizations.translate(language, 'category')),
            const SizedBox(height: 10),
            categoriesAsync.when(
              data: (categories) {
                if (_selectedCategoryId == null && categories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCategoryId = categories.first.id;
                      });
                    }
                  });
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryId == category.id;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcon(category.name),
                            size: 18,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6B48FF),
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                        }
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                AppLocalizations.translate(language, 'category_load_error').replaceFirst('{error}', error.toString()),
                style: const TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 25),
            _buildLabel(AppLocalizations.translate(language, 'billing_interval')),
            const SizedBox(height: 10),
            _buildBillingIntervalSelector(),
            const SizedBox(height: 25),

            _buildLabel(AppLocalizations.translate(language, 'start_date')),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'DD.MM.YYYY'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B48FF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.translate(language, 'save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.translate(language, 'cancel_button'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6B48FF),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A40),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSubscription() async {
    final language = ref.watch(localizationProvider);
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final description = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'please_enter_name'))),
      );
      return;
    }

    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'please_enter_price'))),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'invalid_price'))),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'please_choose_startdate'))),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'please_choose_category'))),
      );
      return;
    }

    if (_selectedBillingInterval.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'please_choose_billing_interval'))),
      );
      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id,
      name: name,
      price: price,
      description: description,
      startDate: _selectedDate!,
      billingInterval: _selectedBillingInterval,
      categoryId: _selectedCategoryId,
    );

    try {
      if (widget.subscription != null) {
        await ref.read(subscriptionListProvider.notifier).updateSubscription(subscription);
      } else {
        await ref.read(subscriptionListProvider.notifier).addSubscription(subscription);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.subscription != null
              ? AppLocalizations.translate(language, 'subscription_updated')
              : AppLocalizations.translate(language, 'subscription_created')),
          duration: const Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.translate(language, 'save_error').replaceFirst('{error}', e.toString()))),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final fillColor = theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade100;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBillingIntervalSelector() {
    final options = const [
      {'key': 'monthly', 'label': 'monatlich'},
      {'key': 'yearly', 'label': 'jährlich'},
    ];

    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final backgroundColor = theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200;
    final unselectedTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Wrap(
      spacing: 10,
      children: options.map((option) {
        final key = option['key'] as String;
        final label = option['label'] as String;
        final selected = _selectedBillingInterval == key;

        return ChoiceChip(
          label: Text(label, style: TextStyle(color: selected ? Colors.white : unselectedTextColor)),
          selected: selected,
          selectedColor: selectedColor,
          backgroundColor: backgroundColor,
          onSelected: (isSelected) {
            if (isSelected) {
              setState(() {
                _selectedBillingInterval = key;
              });
            }
          },
        );
      }).toList(),
    );
  }

  IconData _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'gaming':
        return Icons.sports_esports;
      case 'streaming':
        return Icons.movie;
      case 'mobile':
        return Icons.smartphone;
      case 'musik':
        return Icons.music_note;
      case 'bildung':
        return Icons.school;
      default:
        return Icons.subscriptions_outlined;
    }
  }
}
