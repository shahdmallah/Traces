import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_system.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _messageController = TextEditingController();
  int _selectedChatIndex = 0;
  bool _isMobile = false;

  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Sarah Chen',
      'avatar': 'SC',
      'lastMessage': 'That sounds amazing! When are you planning the trip?',
      'timestamp': '2 min',
      'unread': 2,
      'isOnline': true,
    },
    {
      'name': 'Mountain Adventures Group',
      'avatar': 'MA',
      'lastMessage': 'John: The summit views are incredible this time of year',
      'timestamp': '15 min',
      'unread': 5,
      'isOnline': false,
    },
    {
      'name': 'Michael Rodriguez',
      'avatar': 'MR',
      'lastMessage': 'Thanks for the recommendations!',
      'timestamp': '1 hour',
      'unread': 0,
      'isOnline': true,
    },
    {
      'name': 'Beach Vibes Community',
      'avatar': 'BV',
      'lastMessage': 'Emma: Who wants to go surfing tomorrow?',
      'timestamp': '3 hours',
      'unread': 0,
      'isOnline': false,
    },
    {
      'name': 'Alex Thompson',
      'avatar': 'AT',
      'lastMessage': 'Looking forward to our trip!',
      'timestamp': '1 day',
      'unread': 0,
      'isOnline': false,
    },
  ];

  final List<Map<String, dynamic>> messages = [
    {'sender': 'other', 'text': 'Hey! How are you doing?', 'time': '10:30 AM'},
    {'sender': 'self', 'text': 'I\'m doing great! Just planning my next trip', 'time': '10:32 AM'},
    {'sender': 'other', 'text': 'That sounds amazing! When are you planning the trip?', 'time': '10:33 AM'},
    {'sender': 'self', 'text': 'Thinking of going next month', 'time': '10:34 AM'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isMobile = MediaQuery.of(context).size.width < BreakPoint.tablet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < BreakPoint.tablet;
          
          if (isMobile) {
            // Mobile view: Show either chat list or chat detail
            return _selectedChatIndex == -1 
                ? _buildChatList()
                : _buildChatDetailView();
          } else {
            // Desktop/Tablet view: Show both side by side
            return Row(
              children: [
                SizedBox(width: 320, child: _buildChatList()),
                Expanded(child: _buildChatDetailView()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        // Header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (_isMobile && _selectedChatIndex != -1)
                      IconButton(
                        onPressed: () => setState(() => _selectedChatIndex = -1),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    Expanded(
                      child: Text(
                        'Messages',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                // Search bar
                Semantics(
                  textField: true,
                  enabled: true,
                  label: 'Search conversations',
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: const BorderSide(color: AppColors.beige),
                      ),
                      filled: true,
                      fillColor: AppColors.beige,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Chat list
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isSelected = index == _selectedChatIndex;
              return _buildChatTile(chat, index, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatDetailView() {
    if (_selectedChatIndex == -1 || _selectedChatIndex >= chats.length) {
      return const Center(
        child: Text('Select a conversation to start messaging'),
      );
    }
    
    return Column(
      children: [
        _buildChatHeader(),
        Expanded(
          child: _buildChatView(),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, int index, bool isSelected) {
    return Material(
      color: isSelected ? AppColors.beige : Colors.transparent,
      child: Semantics(
        label: '${chat['name']}, ${chat['lastMessage']}, ${chat['timestamp']} ago',
        button: true,
        enabled: true,
        onTap: () => setState(() => _selectedChatIndex = index),
        child: InkWell(
          onTap: () => setState(() => _selectedChatIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                      child: Text(
                        chat['avatar'] as String,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (chat['isOnline'] as bool)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cream,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat['name'] as String,
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            chat['timestamp'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat['lastMessage'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.stone,
                                  ),
                            ),
                          ),
                          if ((chat['unread'] as int) > 0)
                            Container(
                              margin: const EdgeInsets.only(left: Spacing.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                '${chat['unread']}',
                                style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    final chat = chats[_selectedChatIndex];
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          bottom: BorderSide(
            color: AppColors.beige,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                  child: Text(
                    chat['avatar'] as String,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (chat['isOnline'] as bool)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cream,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'] as String,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    chat['isOnline'] ? 'Active now' : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
              tooltip: 'Start voice call',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call_outlined),
              tooltip: 'Start video call',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      reverse: true, // Show latest messages at bottom
      padding: const EdgeInsets.all(Spacing.lg),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isSelf = message['sender'] == 'self';
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.lg),
          child: Row(
            mainAxisAlignment:
                isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelf ? AppColors.secondary : AppColors.beige,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: isSelf
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelf ? AppColors.cream : AppColors.deepForest,
                            ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        message['time'] as String,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isSelf
                                      ? AppColors.cream.withValues(alpha: 0.85)
                                      : AppColors.stone,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          top: BorderSide(
            color: AppColors.beige,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.beige),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.beige),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                  filled: true,
                  fillColor: AppColors.beige,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.lg),
            IconButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    // Add new message logic here
                    _messageController.clear();
                  });
                }
              },
              icon: const Icon(Icons.send),
              color: AppColors.accent,
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}