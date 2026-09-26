import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddExpenseScreen({Key? key, this.transaction}) : super(key: key);

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late bool _isExpense;
  String? _paymentSlipPath;

  final List<String> _expenseCategories = ['Food', 'Transport', 'Entertainment', 'Bills', 'Shopping', 'Other'];
  final List<String> _incomeCategories = ['Salary', 'Freelance', 'Investments', 'Other'];
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Cheque'];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController = TextEditingController(text: t?.amount.toString() ?? '');
    _notesController = TextEditingController(text: t?.notes ?? '');
    _selectedDate = t?.date ?? DateTime.now();
    _selectedPaymentMethod = t?.paymentMethod ?? 'Cash';
    _paymentSlipPath = t?.paymentSlipPath;
    
    _isExpense = t == null || t.type != 'Income';
    
    if (t != null) {
      if (_isExpense && _expenseCategories.contains(t.category)) {
        _selectedCategory = t.category;
      } else if (!_isExpense && _incomeCategories.contains(t.category)) {
        _selectedCategory = t.category;
      } else {
        _selectedCategory = _isExpense ? _expenseCategories.first : _incomeCategories.first;
      }
    } else {
      _selectedCategory = _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final newTransaction = TransactionModel(
        id: widget.transaction?.id,
        userId: widget.transaction?.userId ?? '', 
        title: _titleController.text,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        type: _isExpense ? 'Expense' : 'Income',
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text,
        paymentSlipPath: _paymentSlipPath,
      );

      if (widget.transaction == null) {
        ref.read(transactionProvider.notifier).addTransaction(newTransaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isExpense ? 'Debit added successfully!' : 'Credit added successfully!'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        
        _titleController.clear();
        _amountController.clear();
        _notesController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategory = _isExpense ? _expenseCategories.first : _incomeCategories.first;
          _selectedPaymentMethod = 'Cash';
          _paymentSlipPath = null;
        });
      } else {
        ref.read(transactionProvider.notifier).updateTransaction(newTransaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully!'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _deleteTransaction() {
    if (widget.transaction?.id != null) {
      ref.read(transactionProvider.notifier).deleteTransaction(widget.transaction!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickPaymentSlip() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentSlipPath = image.path;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1, String? prefixText, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (isOptional && (value == null || value.isEmpty)) return null;
        if (value == null || value.isEmpty) return 'Please enter $hint';
        if (isNumber && double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: Colors.teal, 
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                  if (isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: _deleteTransaction,
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                isEditing 
                    ? (_isExpense ? 'Edit\nDebit.' : 'Edit\nCredit.') 
                    : (_isExpense ? 'Add\nDebit.' : 'Add\nCredit.'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isEditing || _isExpense) return;
                                      setState(() {
                                        _isExpense = true;
                                        _selectedCategory = _expenseCategories.first;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isExpense ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _isExpense ? const [
                                          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 0)
                                        ] : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Debit',
                                        style: TextStyle(
                                          color: _isExpense ? Colors.teal : (isEditing ? Colors.grey.shade400 : Colors.grey.shade600),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isEditing || !_isExpense) return;
                                      setState(() {
                                        _isExpense = false;
                                        _selectedCategory = _incomeCategories.first;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !_isExpense ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: !_isExpense ? const [
                                          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 0)
                                        ] : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Credit',
                                        style: TextStyle(
                                          color: !_isExpense ? Colors.teal : (isEditing ? Colors.grey.shade400 : Colors.grey.shade600),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildTextField(_titleController, 'Shipment Name (Bill, Report) *'),
                          const SizedBox(height: 16),
                          _buildTextField(_amountController, 'Amount *', isNumber: true, prefixText: '₹'),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: currentCategories.map((String category) {
                              return DropdownMenuItem(value: category, child: Text(category));
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedPaymentMethod,
                            decoration: InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: _paymentMethods.map((String method) {
                              return DropdownMenuItem(value: method, child: Text(method));
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedPaymentMethod = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat.yMMMd().format(_selectedDate)),
                                  const Icon(Icons.calendar_today, color: Colors.teal),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(_notesController, 'Notes (Optional)', maxLines: 3, isOptional: true),
                          const SizedBox(height: 16),
                          
                        
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Payment Slip (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _paymentSlipPath != null ? 'Slip attached' : 'No slip attached',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_paymentSlipPath != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_paymentSlipPath!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _paymentSlipPath = null;
                                      });
                                    },
                                  ),
                                ] else
                                  ElevatedButton.icon(
                                    onPressed: _pickPaymentSlip,
                                    icon: const Icon(Icons.attach_file, size: 16),
                                    label: const Text('Attach'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade50,
                                      foregroundColor: Colors.teal,
                                      elevation: 0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saveTransaction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text(_isExpense ? 'Save Debit' : 'Save Credit', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
