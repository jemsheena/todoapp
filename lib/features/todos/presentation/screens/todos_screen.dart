import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../controllers/todos_controller.dart';
import 'add_todo_dialog.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosStateProvider);
    final controller = ref.read(todosStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        elevation: 0,
        actions: [
          if (todosState.error != null)
            IconButton(
              icon: const Icon(Icons.error_outline),
              tooltip: 'Error',
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(todosState.error!)),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: todosState.isLoading && todosState.todos.isEmpty
          ? _buildSkeletonLoader()
          : todosState.todos.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await controller.loadTodos();
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: CustomScrollView(
                    slivers: [
                      if (todosState.pendingTodos.isNotEmpty) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: _buildSectionHeader(
                              context,
                              'Pending',
                              todosState.pendingTodos.length,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final todo = todosState.pendingTodos[index];
                                return _TodoItem(
                                  todo: todo,
                                  index: index,
                                  controller: controller,
                                  animationController: _animationController,
                                );
                              },
                              childCount: todosState.pendingTodos.length,
                            ),
                          ),
                        ),
                      ],
                      if (todosState.completedTodos.isNotEmpty) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: _buildSectionHeader(
                              context,
                              'Completed',
                              todosState.completedTodos.length,
                              isCompleted: true,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final todo = todosState.completedTodos[index];
                                return _TodoItem(
                                  todo: todo,
                                  index: index + todosState.pendingTodos.length,
                                  controller: controller,
                                  animationController: _animationController,
                                  isCompleted: true,
                                );
                              },
                              childCount: todosState.completedTodos.length,
                            ),
                          ),
                        ),
                      ],
                      const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                    ],
                  ),
                ),
      floatingActionButton: _AnimatedFAB(
        animationController: _animationController,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddTodoDialog(context, controller);
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _SkeletonTodoCard(
          delay: Duration(milliseconds: index * 100),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'No todos yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first todo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count, {
    bool isCompleted = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey[600] : null,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.grey[300]
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? Colors.grey[700]
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTodoDialog(BuildContext context, TodosController controller) {
    showDialog(
      context: context,
      builder: (context) => AddTodoDialog(
        onAdd: (title, description, dueDate) {
          controller.addTodo(title, description, dueDate);
        },
      ),
    );
  }
}

class _TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;
  final TodosController controller;
  final AnimationController animationController;
  final bool isCompleted;

  const _TodoItem({
    required this.todo,
    required this.index,
    required this.controller,
    required this.animationController,
    this.isCompleted = false,
  });

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> with SingleTickerProviderStateMixin {
  late AnimationController _dismissController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    HapticFeedback.mediumImpact();
    setState(() => _isDeleting = true);
    await _dismissController.forward();
    widget.controller.deleteTodo(widget.todo.id);
  }

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 50;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          delay / 1000,
          (delay + 400) / 1000,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: _dismissController,
          axisAlignment: -1.0,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: widget.isCompleted ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.selectionClick();
                widget.controller.toggleTodo(widget.todo);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Checkbox(
                        value: widget.todo.isCompleted,
                        onChanged: (_) {
                          HapticFeedback.mediumImpact();
                          widget.controller.toggleTodo(widget.todo);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: widget.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.isCompleted
                                  ? Colors.grey[500]
                                  : null,
                            ),
                          ),
                          if (widget.todo.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.todo.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: widget.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                                                     if (widget.todo.dueDate != null) ...[
                             const SizedBox(height: 8),
                             Row(
                               children: [
                                 Icon(
                                   Icons.calendar_today,
                                   size: 14,
                                   color: _getDueDateColor(context, widget.todo.dueDate!),
                                 ),
                                 const SizedBox(width: 4),
                                 Text(
                                   _formatDate(widget.todo.dueDate!),
                                   style: TextStyle(
                                     fontSize: 12,
                                     fontWeight: FontWeight.w500,
                                     color: _getDueDateColor(context, widget.todo.dueDate!),
                                   ),
                                 ),
                               ],
                             ),
                           ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red[300],
                      onPressed: _isDeleting ? null : _handleDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getDueDateColor(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return Colors.red;
    } else if (difference == 0) {
      return Colors.orange;
    } else if (difference <= 3) {
      return Colors.amber;
    }
    return Colors.grey[600];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todoDate = DateTime(date.year, date.month, date.day);

    if (todoDate == today) {
      return 'Today';
    } else if (todoDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SkeletonTodoCard extends StatefulWidget {
  final Duration delay;

  const _SkeletonTodoCard({required this.delay});

  @override
  State<_SkeletonTodoCard> createState() => _SkeletonTodoCardState();
}

class _SkeletonTodoCardState extends State<_SkeletonTodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_controller.value * 0.5),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedFAB extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onPressed;

  const _AnimatedFAB({
    required this.animationController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
        elevation: 4,
      ),
    );
  }
}
