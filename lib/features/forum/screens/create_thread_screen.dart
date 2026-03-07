import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forum_provider.dart';

class CreateThreadScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const CreateThreadScreen({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _selectedTags = [];
  String? _selectedCategoryId;
  bool _isSubmitting = false;
  bool _showPreview = false;
  bool _addPoll = false;

  final List<Map<String, dynamic>> _pollOptions = [];
  final TextEditingController _pollQuestionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    ref.read(forumProvider.notifier).fetchCategories();
  }

  Future<void> _submitThread() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final threadData = {
      'title': _titleController.text,
      'content': _contentController.text,
      'category': _selectedCategoryId,
      'tags': _selectedTags,
      if (_addPoll &&
          _pollQuestionController.text.isNotEmpty &&
          _pollOptions.isNotEmpty)
        'poll': {
          'question': _pollQuestionController.text,
          'options': _pollOptions.map((opt) => opt['text']).toList(),
        },
    };

    final success =
        await ref.read(forumProvider.notifier).createThread(threadData);

    setState(() => _isSubmitting = false);

    if (success) {
      widget.onSuccess();
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _addPollOption() {
    if (_pollOptions.length < 10) {
      setState(() {
        _pollOptions.add({'text': '', 'controller': TextEditingController()});
      });
    }
  }

  void _removePollOption(int index) {
    setState(() {
      _pollOptions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(forumProvider).categories;
    final isLoadingCategories = ref.watch(forumProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: widget.onCancel,
            ),
            title: const Text(
              'Create New Thread',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitThread,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                        const Color(0xFF0066FF).withValues(alpha: 0.5),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: const Text(
                    'Publish',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          // Form content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.8),
                            const Color(0xFF0F172A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thread Title',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText:
                                  'Enter a clear and descriptive title...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF00CCFF), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                            ),
                            maxLength: 200,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              if (value.trim().length < 10) {
                                return 'Title must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // Category selector
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.8),
                            const Color(0xFF0F172A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Category',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isLoadingCategories)
                            const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF00CCFF)),
                            )
                          else if (categories.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Center(
                                child: Text(
                                  'No categories available',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categories.map((category) {
                                final isSelected =
                                    _selectedCategoryId == category.id;
                                return ChoiceChip(
                                  label: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategoryId =
                                          isSelected ? null : category.id;
                                    });
                                  },
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.05),
                                  selectedColor: const Color(0xFF0066FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF0066FF)
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    // Tags
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.8),
                            const Color(0xFF0F172A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add up to 5 tags to help others find your thread',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Tag input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Add a tag...',
                                    hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF00CCFF), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.05),
                                  ),
                                  onSubmitted: (_) => _addTag(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _addTag,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 20),
                              ),
                            ],
                          ),

                          // Selected tags
                          if (_selectedTags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '#$tag',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => _removeTag(tag),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Content editor/preview toggle
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.8),
                            const Color(0xFF0F172A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Content',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ToggleButtons(
                                isSelected: [!_showPreview, _showPreview],
                                onPressed: (index) {
                                  setState(() {
                                    _showPreview = index == 1;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                selectedBorderColor: const Color(0xFF0066FF),
                                selectedColor: Colors.white,
                                fillColor:
                                    const Color(0xFF0066FF).withValues(alpha: 0.2),
                                color: Colors.white.withValues(alpha: 0.5),
                                constraints: const BoxConstraints(
                                  minHeight: 36,
                                  minWidth: 80,
                                ),
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Write',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Preview',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (!_showPreview)
                            TextFormField(
                              controller: _contentController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              maxLines: 15,
                              decoration: InputDecoration(
                                hintText:
                                    'Write your content here (Markdown supported)...\n\n**Tips:**\n- Use # for headings\n- Use * for lists\n- Use > for quotes\n- Use `code` for inline code',
                                hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF00CCFF), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter content';
                                }
                                if (value.trim().length < 20) {
                                  return 'Content must be at least 20 characters';
                                }
                                return null;
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: MarkdownBody(
                                data: _contentController.text.isEmpty
                                    ? '*No content to preview*'
                                    : _contentController.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5),
                                  h1: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                  h2: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                  h3: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                  a: const TextStyle(
                                      color: Color(0xFF00CCFF),
                                      decoration: TextDecoration.underline),
                                  code: TextStyle(
                                      color: Colors.white,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.05),
                                      fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Poll section
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E293B).withValues(alpha: 0.8),
                            const Color(0xFF0F172A).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _addPoll,
                                onChanged: (value) {
                                  setState(() {
                                    _addPoll = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF0066FF),
                                checkColor: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Add a Poll',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (_addPoll) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pollQuestionController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Poll Question',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                hintText: 'Ask a question for your poll...',
                                hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF00CCFF), width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              'Poll Options',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Poll options
                            ..._pollOptions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              final controller =
                                  option['controller'] as TextEditingController;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: 'Option ${index + 1}',
                                          hintStyle: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.4)),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.white
                                                    .withValues(alpha: 0.1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.white
                                                    .withValues(alpha: 0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF00CCFF),
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withValues(alpha: 0.05),
                                          prefixIcon: Icon(
                                            Icons.radio_button_unchecked,
                                            color:
                                                Colors.white.withValues(alpha: 0.3),
                                            size: 20,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _pollOptions[index]['text'] = value;
                                          });
                                        },
                                      ),
                                    ),
                                    if (_pollOptions.length > 2)
                                      IconButton(
                                        onPressed: () =>
                                            _removePollOption(index),
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red.withValues(alpha: 0.7),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),

                            if (_pollOptions.length < 10)
                              ElevatedButton.icon(
                                onPressed: _addPollOption,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.05),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Option'),
                              ),

                            const SizedBox(height: 16),
                            Text(
                              '${_pollOptions.length}/10 options',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Bottom padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    for (final option in _pollOptions) {
      (option['controller'] as TextEditingController).dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
