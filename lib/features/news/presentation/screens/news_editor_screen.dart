import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/providers/news_provider.dart';
import '../../data/providers/category_provider.dart';
import '../widgets/editor/rich_text_editor.dart';
import '../widgets/editor/media_uploader.dart';
import '../../../../core/utils/toast_utils.dart';

class NewsEditorScreen extends ConsumerStatefulWidget {
  final NewsArticle? article;

  const NewsEditorScreen({super.key, this.article});

  @override
  ConsumerState<NewsEditorScreen> createState() => _NewsEditorScreenState();
}

class _NewsEditorScreenState extends ConsumerState<NewsEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  final _seoTitleController = TextEditingController();
  final _seoDescriptionController = TextEditingController();
  final _metaKeywordsController = TextEditingController();
  final _canonicalUrlController = TextEditingController();
  final _sourceController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _reviewNotesController = TextEditingController();

  NewsStatus _selectedStatus = NewsStatus.draft;
  NewsPriority _selectedPriority = NewsPriority.medium;
  String? _selectedCategoryId;
  bool _isFeatured = false;
  bool _isBreaking = false;
  bool _isSponsored = false;
  bool _isExclusive = false;
  DateTime? _scheduledFor;
  DateTime? _expiresAt;
  List<String> _tags = [];
  List<String> _coAuthors = [];
  String? _featuredImage;
  List<String> _imageGallery = [];

  @override
  void initState() {
    super.initState();
    _initializeFromArticle();
    ref.read(categoryProvider.notifier).fetchCategories();
  }

  void _initializeFromArticle() {
    if (widget.article != null) {
      final article = widget.article!;
      _titleController.text = article.title;
      _summaryController.text = article.summary;
      _contentController.text = article.content;
      _excerptController.text = article.excerpt ?? '';
      _seoTitleController.text = article.seoTitle ?? '';
      _seoDescriptionController.text = article.seoDescription ?? '';
      _metaKeywordsController.text = article.metaKeywords.join(', ');
      _canonicalUrlController.text = article.canonicalUrl ?? '';
      _sourceController.text = article.source ?? '';
      _sourceUrlController.text = article.sourceUrl ?? '';
      _selectedStatus = article.status;
      _selectedPriority = article.priority;
      _selectedCategoryId = article.category.id;
      _isFeatured = article.isFeatured;
      _isBreaking = article.isBreaking;
      _isSponsored = article.isSponsored;
      _isExclusive = article.isExclusive;
      _scheduledFor = article.scheduledFor;
      _expiresAt = article.expiresAt;
      _tags = article.tags;
      _coAuthors = article.coAuthors.map((author) => author.id).toList();
      _featuredImage = article.featuredImage;
      _imageGallery = article.imageGallery;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    _seoTitleController.dispose();
    _seoDescriptionController.dispose();
    _metaKeywordsController.dispose();
    _canonicalUrlController.dispose();
    _sourceController.dispose();
    _sourceUrlController.dispose();
    _reviewNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveArticle(bool publish) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'title': _titleController.text,
      'summary': _summaryController.text,
      'content': _contentController.text,
      'excerpt': _excerptController.text,
      'category': _selectedCategoryId,
      'tags': _tags,
      'status': publish ? NewsStatus.published.name : _selectedStatus.name,
      'priority': _selectedPriority.name,
      'isFeatured': _isFeatured,
      'isBreaking': _isBreaking,
      'isSponsored': _isSponsored,
      'isExclusive': _isExclusive,
      'scheduledFor': _scheduledFor?.toIso8601String(),
      'expiresAt': _expiresAt?.toIso8601String(),
      'seoTitle': _seoTitleController.text,
      'seoDescription': _seoDescriptionController.text,
      'metaKeywords': _metaKeywordsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'canonicalUrl': _canonicalUrlController.text,
      'source': _sourceController.text,
      'sourceUrl': _sourceUrlController.text,
      'coAuthors': _coAuthors,
    };

    try {
      if (widget.article != null) {
        await ref.read(newsProvider.notifier).updateNews(widget.article!.id, data, null);
      } else {
        await ref.read(newsProvider.notifier).createNews(data, null);
      }

      ToastUtils.showSuccessToast(
          publish ? 'News published successfully' : 'News saved successfully'
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to save news');
    }
  }

  Future<void> _pickDate(BuildContext context, bool isScheduled) async {
    final initialDate = isScheduled ? _scheduledFor : _expiresAt;
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isScheduled) {
          _scheduledFor = pickedDate;
        } else {
          _expiresAt = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider).categories;
    final isLoading = ref.watch(newsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article != null ? 'Edit News' : 'Create News'),
        actions: [
          if (widget.article != null)
            IconButton(
              onPressed: () => _showDeleteDialog(),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          IconButton(
            onPressed: () => _saveArticle(false),
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () => _saveArticle(true),
            icon: const Icon(Icons.publish),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              _buildTextField(_titleController, 'Title', maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(_summaryController, 'Summary', maxLines: 3),
              const SizedBox(height: 16),
              _buildCategoryDropdown(categories.cast<NewsCategory>()),
              const SizedBox(height: 16),

              // Content
              _buildSectionTitle('Content'),
              RichTextEditor(
                controller: _contentController,
                onChanged: (value) {
                  // Update content
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_excerptController, 'Excerpt (Optional)', maxLines: 3),

              // Media
              _buildSectionTitle('Media'),
              MediaUploader(
                featuredImage: _featuredImage,
                imageGallery: _imageGallery,
                onFeaturedImageChanged: (image) {
                  setState(() => _featuredImage = image);
                },
                onImageGalleryChanged: (gallery) {
                  setState(() => _imageGallery = gallery);
                },
              ),

              // Settings
              _buildSectionTitle('Settings'),
              _buildStatusAndPriority(),
              const SizedBox(height: 16),
              _buildFlags(),
              const SizedBox(height: 16),
              _buildScheduleSettings(),

              // SEO
              _buildSectionTitle('SEO'),
              _buildTextField(_seoTitleController, 'SEO Title (Optional)'),
              const SizedBox(height: 16),
              _buildTextField(_seoDescriptionController, 'SEO Description (Optional)', maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(_metaKeywordsController, 'Meta Keywords (comma separated)'),
              const SizedBox(height: 16),
              _buildTextField(_canonicalUrlController, 'Canonical URL (Optional)'),

              // Source
              _buildSectionTitle('Source'),
              _buildTextField(_sourceController, 'Source (Optional)'),
              const SizedBox(height: 16),
              _buildTextField(_sourceUrlController, 'Source URL (Optional)'),

              // Tags
              _buildSectionTitle('Tags'),
              _buildTagsInput(),

              // Co-authors
              _buildSectionTitle('Co-authors'),
              _buildCoAuthorsInput(),

              // Review notes (for moderators)
              if (widget.article != null && widget.article!.isPendingReview)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Review Notes'),
                    _buildTextField(_reviewNotesController, 'Review Notes', maxLines: 4),
                  ],
                ),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (label == 'Title' && (value == null || value.isEmpty)) {
          return 'Title is required';
        }
        if (label == 'Summary' && (value == null || value.isEmpty)) {
          return 'Summary is required';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(List<NewsCategory> categories) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
      },
      validator: (value) => value == null ? 'Category is required' : null,
    );
  }

  Widget _buildStatusAndPriority() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<NewsStatus>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: NewsStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<NewsPriority>(
            value: _selectedPriority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: NewsPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPriority = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlags() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: _isFeatured,
          label: const Text('Featured'),
          onSelected: (selected) => setState(() => _isFeatured = selected),
        ),
        FilterChip(
          selected: _isBreaking,
          label: const Text('Breaking'),
          onSelected: (selected) => setState(() => _isBreaking = selected),
        ),
        FilterChip(
          selected: _isSponsored,
          label: const Text('Sponsored'),
          onSelected: (selected) => setState(() => _isSponsored = selected),
        ),
        FilterChip(
          selected: _isExclusive,
          label: const Text('Exclusive'),
          onSelected: (selected) => setState(() => _isExclusive = selected),
        ),
      ],
    );
  }

  Widget _buildScheduleSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Schedule For'),
                subtitle: Text(_scheduledFor != null
                    ? '${_scheduledFor!.day}/${_scheduledFor!.month}/${_scheduledFor!.year}'
                    : 'Not scheduled'),
                trailing: IconButton(
                  onPressed: () => _pickDate(context, true),
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Expires At'),
                subtitle: Text(_expiresAt != null
                    ? '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'
                    : 'No expiration'),
                trailing: IconButton(
                  onPressed: () => _pickDate(context, false),
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._tags.map((tag) => Chip(
          label: Text(tag),
          onDeleted: () {
            setState(() => _tags.remove(tag));
          },
        )).toList(),
        InputChip(
          label: const Row(
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 4),
              Text('Add Tag'),
            ],
          ),
          onPressed: () => _showAddTagDialog(),
        ),
      ],
    );
  }

  Widget _buildCoAuthorsInput() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._coAuthors.map((author) => Chip(
          label: const Text('Co-author'),
          onDeleted: () {
            setState(() => _coAuthors.remove(author));
          },
        )).toList(),
        InputChip(
          label: const Row(
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 4),
              Text('Add Co-author'),
            ],
          ),
          onPressed: () => _showAddCoAuthorDialog(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveArticle(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Save Draft'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveArticle(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Publish'),
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter tag'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCoAuthorDialog() {
    // In a real app, this would show a user search/selection dialog
    ToastUtils.showInfoToast('Co-author functionality not implemented');
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News Article'),
        content: const Text('Are you sure you want to delete this news article? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteArticle();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteArticle() async {
    if (widget.article != null) {
      final success = await ref.read(newsProvider.notifier).deleteNews(widget.article!.id);
      if (success && mounted) {
        ToastUtils.showSuccessToast('News article deleted');
        Navigator.pop(context);
      }
    }
  }
}