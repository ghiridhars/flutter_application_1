import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoListPage(),
    );
  }
}

// Model class for Todo items
class Todo {
  String title;
  bool isCompleted;
  DateTime createdAt;
  String category;

  Todo({
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.category = 'Personal',
  }) : createdAt = createdAt ?? DateTime.now();
}

// Available categories
enum TodoCategory {
  personal('Personal', Icons.person, Colors.blue),
  work('Work', Icons.work, Colors.orange),
  shopping('Shopping', Icons.shopping_cart, Colors.green),
  health('Health', Icons.favorite, Colors.red),
  study('Study', Icons.school, Colors.purple);

  final String label;
  final IconData icon;
  final Color color;
  
  const TodoCategory(this.label, this.icon, this.color);
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // List to store all todos
  final List<Todo> _todos = [];
  
  // Controller for the text input field
  final TextEditingController _textController = TextEditingController();
  
  // Filter state: 'all', 'active', 'completed'
  String _filter = 'all';
  
  // Selected category for new todos
  String _selectedCategory = 'Personal';

  // Add a new todo
  void _addTodo() {
    if (_textController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _todos.add(Todo(
        title: _textController.text.trim(),
        category: _selectedCategory,
      ));
      _textController.clear();
    });
  }

  // Toggle todo completion status
  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  // Delete a todo
  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  // Get filtered todos based on current filter
  List<Todo> get _filteredTodos {
    switch (_filter) {
      case 'active':
        return _todos.where((todo) => !todo.isCompleted).toList();
      case 'completed':
        return _todos.where((todo) => todo.isCompleted).toList();
      default:
        return _todos;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Format timestamp for display
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Get category icon
  IconData _getCategoryIcon(String category) {
    return TodoCategory.values
        .firstWhere(
          (cat) => cat.label == category,
          orElse: () => TodoCategory.personal,
        )
        .icon;
  }

  // Get category color
  Color _getCategoryColor(String category) {
    return TodoCategory.values
        .firstWhere(
          (cat) => cat.label == category,
          orElse: () => TodoCategory.personal,
        )
        .color;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _filteredTodos;
    final activeCount = _todos.where((todo) => !todo.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('My Todo List'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Input section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'What needs to be done?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            _getCategoryIcon(_selectedCategory),
                            color: _getCategoryColor(_selectedCategory),
                          ),
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addTodo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Category selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TodoCategory.values.map((category) {
                      final isSelected = _selectedCategory == category.label;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 16,
                                color: isSelected ? Colors.white : category.color,
                              ),
                              const SizedBox(width: 4),
                              Text(category.label),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: category.color,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category.label;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'all';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _filter == 'active',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'active';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _filter == 'completed',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'completed';
                    });
                  },
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$activeCount ${activeCount == 1 ? 'item' : 'items'} left',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          // Todo list
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'completed'
                              ? 'No completed tasks yet'
                              : _filter == 'active'
                                  ? 'No active tasks'
                                  : 'No tasks yet. Add one above!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      final originalIndex = _todos.indexOf(todo);

                      return Dismissible(
                        key: Key(todo.createdAt.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTodo(originalIndex),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: _getCategoryColor(todo.category).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _getCategoryIcon(todo.category),
                                color: _getCategoryColor(todo.category),
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (_) => _toggleTodo(originalIndex),
                                ),
                                Expanded(
                                  child: Text(
                                    todo.title,
                                    style: TextStyle(
                                      decoration: todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: todo.isCompleted
                                          ? Colors.grey
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(left: 48.0, top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTimestamp(todo.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(todo.category).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getCategoryColor(todo.category).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      todo.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _getCategoryColor(todo.category),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => _deleteTodo(originalIndex),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
