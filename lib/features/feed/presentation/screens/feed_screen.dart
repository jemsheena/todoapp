import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 1000));
        },
        color: Theme.of(context).colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FeedCard(
              animationController: _animationController,
              index: 0,
              avatarColor: Colors.blue,
              userName: 'You',
              timeAgo: '2 hours ago',
              content: 'Completed 5 todos today! 🎉',
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
            _FeedCard(
              animationController: _animationController,
              index: 1,
              avatarColor: Colors.purple,
              userName: 'Team Member',
              timeAgo: '5 hours ago',
              content: 'Just finished the project milestone. Great progress! 💪',
              icon: Icons.celebration,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            _FeedCard(
              animationController: _animationController,
              index: 2,
              avatarColor: Colors.teal,
              userName: 'You',
              timeAgo: '1 day ago',
              content: 'Set a new personal record: 10 todos completed! 🏆',
              icon: Icons.emoji_events,
              iconColor: Colors.amber,
            ),
            const SizedBox(height: 16),
            _FeedCard(
              animationController: _animationController,
              index: 3,
              avatarColor: Colors.pink,
              userName: 'Friend',
              timeAgo: '2 days ago',
              content: 'Started a new todo list for the week. Let\'s stay organized! ✨',
              icon: Icons.list,
              iconColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final AnimationController animationController;
  final int index;
  final Color avatarColor;
  final String userName;
  final String timeAgo;
  final String content;
  final IconData icon;
  final Color iconColor;

  const _FeedCard({
    required this.animationController,
    required this.index,
    required this.avatarColor,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 100;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          delay / 1000,
          (delay + 300) / 1000,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.selectionClick();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              avatarColor.withOpacity(0.8),
                              avatarColor,
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: avatarColor,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeAgo,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
