import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const app = MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PremiumChatScreen(),
  );

  final dispatcher = WidgetsBinding.instance.platformDispatcher;

  // Normal mode (Stable)
  if (dispatcher.implicitView != null) {
    runApp(app);
    return;
  }

  // Multi-view mode (Beta): view aane ka intezaar karo
  var tries = 0;
  while (dispatcher.views.isEmpty && tries < 100) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    tries++;
  }

  if (dispatcher.views.isEmpty) {
    runApp(app);
    return;
  }

  runWidget(
    View(
      view: dispatcher.views.first,
      child: app,
    ),
  );
}

class PremiumChatScreen extends StatefulWidget {
  const PremiumChatScreen({super.key});

  @override
  State<PremiumChatScreen> createState() => _PremiumChatScreenState();
}

class _PremiumChatScreenState extends State<PremiumChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _showQuickStart = true;
  int _pendingResponses = 0;

  static const List<_Prompt> _prompts = [
    _Prompt('Landing page code', Icons.code_rounded),
    _Prompt('Idea ko plan banao', Icons.lightbulb_outline_rounded),
    _Prompt('Email polish karo', Icons.edit_note_rounded),
    _Prompt('Bug fix karo', Icons.bug_report_outlined),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        fromUser: true,
        time: DateTime.now(),
      ));
      _showQuickStart = false;
      _pendingResponses++;
    });

    _controller.clear();
    _scrollToEnd();

    await Future<void>.delayed(
      const Duration(milliseconds: 1600),
    );

    if (!mounted) return;

    setState(() {
      _pendingResponses--;
      _messages.add(_ChatMessage(
        text: 'Main ready hoon ✨ Aapka plan, code ya content bataiye—'
            'premium mode mein detailed response milega.',
        fromUser: false,
        time: DateTime.now(),
      ));
    });

    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _showPlanSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => const _PremiumPlanSheet(),
    );
  }

  void _showAttachmentMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Camera, gallery aur document upload yahan connect hoga.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Colors.surface2,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildChat()),
                _buildComposer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      decoration: BoxDecoration(
        color: _Colors.background.withOpacity(0.94),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_Colors.purple, _Colors.purpleDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _Colors.purple.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _Colors.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayan AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _Colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, color: _Colors.green, size: 7),
                    SizedBox(width: 6),
                    Text(
                      'Premium model • Online',
                      style: TextStyle(
                        color: _Colors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Colors.gold, Color(0xFFFFD98A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showPlanSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 15,
                        color: Color(0xFF111111),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _showPlanSheet,
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: _Colors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            _buildDayDivider(),
            if (_showQuickStart) ...[
              _buildPremiumBanner(),
              const SizedBox(height: 28),
              _buildWelcome(),
              const SizedBox(height: 24),
              const Text(
                'QUICK START',
                style: TextStyle(
                  color: _Colors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _prompts.map((prompt) {
                  return ActionChip(
                    onPressed: () => _sendMessage(prompt.title),
                    avatar: Icon(
                      prompt.icon,
                      size: 16,
                      color: _Colors.purple,
                    ),
                    label: Text(prompt.title),
                    backgroundColor: _Colors.surface,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                    ),
                    labelStyle: const TextStyle(
                      color: _Colors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
            ],
            ..._messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMessageBubble(message),
              ),
            ),
            if (_pendingResponses > 0) _buildTypingBubble(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.07)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'TODAY',
            style: TextStyle(
              color: _Colors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.07)),
        ),
      ],
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D1530), Color(0xFF101010)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _Colors.purple.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_Colors.purple, _Colors.purpleDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium AI Access',
                      style: TextStyle(
                        color: _Colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Unlimited messages & priority responses',
                      style: TextStyle(
                        color: _Colors.text,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _Colors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: _Colors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'All premium models are unlocked',
                  style: TextStyle(
                    color: _Colors.text,
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton(
                onPressed: _showPlanSheet,
                style: TextButton.styleFrom(
                  foregroundColor: _Colors.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Namaste 👋',
          style: TextStyle(
            color: _Colors.gold,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              _Colors.purple,
              _Colors.gold,
            ],
          ).createShader(bounds),
          child: const Text(
            'Aapke liye kya banaun?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Coding, writing, planning ya content—sab kuch '
          'ek premium AI assistant ke saath.',
          style: TextStyle(
            color: _Colors.text,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth < 600 ? screenWidth * 0.84 : 560.0;

    return Align(
      alignment:
          message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: message.fromUser
                ? const LinearGradient(
                    colors: [_Colors.purple, _Colors.purpleDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: message.fromUser ? null : _Colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(message.fromUser ? 20 : 6),
              topRight: Radius.circular(message.fromUser ? 6 : 20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
            ),
            border: message.fromUser
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.07),
                  ),
            boxShadow: message.fromUser
                ? [
                    BoxShadow(
                      color: _Colors.purple.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: message.fromUser
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _formatTime(message.time),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _Colors.purple.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: _Colors.purple,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: const TextStyle(
                              color: _Colors.text,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'AI • ${_formatTime(message.time)}',
                              style: const TextStyle(
                                color: _Colors.muted,
                                fontSize: 9,
                              ),
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
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: _Colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: _Colors.purple,
              size: 15,
            ),
            SizedBox(width: 10),
            _TypingDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withOpacity(0.97),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              color: _Colors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _showAttachmentMessage,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.add_rounded,
                    color: _Colors.text,
                    size: 23,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: _Colors.text,
                  fontSize: 14,
                ),
                cursorColor: _Colors.purple,
                decoration: InputDecoration(
                  hintText: 'Message Ayan AI...',
                  hintStyle: const TextStyle(
                    color: _Colors.muted,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: _Colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _Colors.purple.withOpacity(0.65),
                    ),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final enabled = value.text.trim().isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: enabled
                        ? const LinearGradient(
                            colors: [
                              _Colors.purple,
                              _Colors.purpleDark,
                            ],
                          )
                        : null,
                    color: enabled ? null : _Colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: _Colors.purple.withOpacity(0.30),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: enabled ? () => _sendMessage() : null,
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        color: enabled ? Colors.white : _Colors.muted,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PremiumPlanSheet extends StatelessWidget {
  const _PremiumPlanSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF2B2B2B)),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_Colors.purple, _Colors.purpleDark],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Premium',
                        style: TextStyle(
                          color: _Colors.text,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'All limits unlocked',
                        style: TextStyle(
                          color: _Colors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _Colors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: _Colors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹499',
                  style: TextStyle(
                    color: _Colors.text,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 7, left: 6),
                  child: Text(
                    '/ month',
                    style: TextStyle(
                      color: _Colors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...[
              'Unlimited AI messages',
              'Premium advanced models',
              'Priority AI responses',
              'Image and document analysis',
              'Priority support',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _Colors.purple,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      feature,
                      style: const TextStyle(
                        color: _Colors.text,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_Colors.purple, _Colors.purpleDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const SizedBox(
                    height: 54,
                    child: Center(
                      child: Text(
                        'Manage Premium Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Cancel anytime • Secure billing',
                style: TextStyle(
                  color: _Colors.muted,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value - index * 0.18) % 1.0;
            final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;

            return Transform.translate(
              offset: Offset(0, -3 * wave),
              child: Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _Colors.purple.withOpacity(0.4 + wave * 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _Colors.purple.withOpacity(0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -140,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _Colors.gold.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.fromUser,
    required this.time,
  });

  final String text;
  final bool fromUser;
  final DateTime time;
}

class _Prompt {
  const _Prompt(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _Colors {
  static const background = Color(0xFF070707);
  static const surface = Color(0xFF121212);
  static const surface2 = Color(0xFF1A1A1A);
  static const purple = Color(0xFF9A6CFF);
  static const purpleDark = Color(0xFF6C3BFF);
  static const gold = Color(0xFFF5C86B);
  static const text = Color(0xFFF7F7F8);
  static const muted = Color(0xFF85858F);
  static const green = Color(0xFF44D7A8);
}