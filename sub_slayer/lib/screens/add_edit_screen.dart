import 'package:flutter/material.dart';

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  // Controller für die Textfelder
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Status-Variablen für Kategorie und Datum
  String _selectedCategory = 'Streaming'; // Standardwert
  DateTime? _selectedDate;

  // Liste der Kategorien mit passenden Icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Gaming', 'icon': Icons.sports_esports, 'color': Colors.deepPurple},
    {'name': 'Streaming', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Mobile', 'icon': Icons.smartphone, 'color': Colors.orange},
    {'name': 'Musik', 'icon': Icons.music_note, 'color': Colors.blueAccent},
    {'name': 'Bildung', 'icon': Icons.school, 'color': Colors.green},
  ];

  // Methode zum Öffnen des Kalenders
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
              primary: Color(0xFF6B48FF), // Das Violett für den Kalender
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubSeeker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- EINGABEFELDER ---
            _buildLabel('Name des Abos'),
            _buildTextField(
              controller: _nameController,
              hintText: 'z.B. Netflix',
            ),
            const SizedBox(height: 20),

            _buildLabel('Preis'),
            _buildTextField(
              controller: _priceController,
              hintText: 'z.B. 12,99 €',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            _buildLabel('Beschreibung (optional)'),
            _buildTextField(
              controller: _descController,
              hintText: 'Monatliches Streaming-Abo',
            ),
            const SizedBox(height: 25),

            // --- KATEGORIEN ---
            _buildLabel('Kategorie'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['name'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'],
                        size: 18,
                        color: isSelected ? Colors.white : category['color'],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['name'],
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
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            // --- STARTDATUM ---
            _buildLabel('Startdatum'),
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

            // --- BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Mit Backend/Riverpod verbinden und speichern
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B48FF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Speichern', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Zurück ohne Speichern
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Abbrechen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hilfs-Widget für die weißen Textfelder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Hilfs-Widget für die kleinen Labels über den Feldern
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
}