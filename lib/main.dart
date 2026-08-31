import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/models/todo.dart';
import 'package:spend_wise/screens/expense_screen.dart';
import 'package:spend_wise/screens/todo_screen.dart';
import 'package:spend_wise/screens/dashboard_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // Deep Teal
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color(0xFFF1F5F9),
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF0F766E),
          ),
        ),
      ),
      home: const SpendWiseHome(),
    );
  }
}

class SpendWiseHome extends StatefulWidget {
  const SpendWiseHome({super.key});

  @override
  State<SpendWiseHome> createState() => _SpendWiseHomeState();
}


class _SpendWiseHomeState extends State<SpendWiseHome> {
  static const String _expensesKey = 'spendwise_expenses';
  static const String _todosKey = 'spendwise_todos';
  int _selectedTab = 0;

  final List<Expense> _expenses = <Expense>[];
  final List<Todo> _todos = <Todo>[];

// ── ACTION METHODS ───────────

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> savedExpenses =
        prefs.getStringList(_expensesKey) ?? <String>[];
    final List<String> savedTodos =
        prefs.getStringList(_todosKey) ?? <String>[];

    final List<Expense> parsedExpenses = savedExpenses.map((String item) {
      final dynamic decoded = jsonDecode(item);
      return Expense.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      );
    }).toList();

    final List<Todo> parsedTodos = savedTodos.map((String item) {
      final dynamic decoded = jsonDecode(item);
      return Todo.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      );
    }).toList();

    if (!mounted) return;

    setState(() {
      _expenses
        ..clear()
        ..addAll(parsedExpenses)
        ..sort((Expense a, Expense b) => b.date.compareTo(a.date));
      _todos
        ..clear()
        ..addAll(parsedTodos)
        ..sort((Todo a, Todo b) {
          if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
          return b.createdAt.compareTo(a.createdAt);
        });
    });
  }

  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> expenseJson = _expenses
        .map((Expense item) => jsonEncode(item.toJson()))
        .toList();

    final List<String> todoJson = _todos
        .map((Todo item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_expensesKey, expenseJson);
    await prefs.setStringList(_todosKey, todoJson);
  }


  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(
          expenses: _expenses,
          todos: _todos,
        ),
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
      _expenses.sort((Expense a, Expense b) => b.date.compareTo(a.date));
    });
    _saveData();
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
    _saveData();
  }

  void _addTodo(String title) {
    setState(() {
      _todos.add(Todo(title: title, createdAt: DateTime.now()));
    });
    _saveData();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveData();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
      _todos.sort((Todo a, Todo b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
    });
    _saveData();
  }

// ── BUILD ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>['Expenses', 'Todo List'];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[_selectedTab]),
          actions: [
            IconButton(
              onPressed: _openDashboard,
              icon: const Icon(Icons.dashboard_outlined),
              tooltip: 'Open dashboard',
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            _selectedTab == 0
                ? ExpenseScreen(
                    expenses: _expenses,
                    onAddExpense: _addExpense,
                    onDeleteExpense: _deleteExpense,
                  )
                : TodoScreen(
                    todos: _todos,
                    onAddTodo: _addTodo,
                    onToggleTodo: _toggleTodo,
                    onDeleteTodo: _deleteTodo,
                  ),
          ],
        ),


        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          selectedItemColor: const Color(0xFF0F766E),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              _selectedTab = index;
            });
          },


          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              label: 'Todo',
            ),
          ],
        ),
      ),
    );
  }
}
