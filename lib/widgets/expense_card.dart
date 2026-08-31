import 'package:flutter/material.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFCCFBF1),
          foregroundColor: const Color(0xFF0F766E),
          child: Text(expense.category.label.substring(0, 2)),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.category.label} • ${DateFormat.yMMMd().format(expense.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '₹${expense.amount.toStringAsFixed(3)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}