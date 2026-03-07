import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;

  const RichTextEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isBulletList = false;
  bool _isNumberedList = false;
  bool _isLink = false;
  bool _isImage = false;
  bool _isVideo = false;

  void _toggleBold() {
    setState(() => _isBold = !_isBold);
    // In a real app, this would format the selected text
  }

  void _toggleItalic() {
    setState(() => _isItalic = !_isItalic);
  }

  void _toggleUnderline() {
    setState(() => _isUnderline = !_isUnderline);
  }

  void _toggleBulletList() {
    setState(() {
      _isBulletList = !_isBulletList;
      _isNumberedList = false;
    });
  }

  void _toggleNumberedList() {
    setState(() {
      _isNumberedList = !_isNumberedList;
      _isBulletList = false;
    });
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Link Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Insert link logic
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _insertImage() {
    // Trigger image upload
  }

  void _insertVideo() {
    // Trigger video upload
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Text formatting
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  isActive: _isBold,
                  onPressed: _toggleBold,
                  tooltip: 'Bold',
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  isActive: _isItalic,
                  onPressed: _toggleItalic,
                  tooltip: 'Italic',
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  isActive: _isUnderline,
                  onPressed: _toggleUnderline,
                  tooltip: 'Underline',
                ),

                const VerticalDivider(width: 1),

                // Lists
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  isActive: _isBulletList,
                  onPressed: _toggleBulletList,
                  tooltip: 'Bullet List',
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  isActive: _isNumberedList,
                  onPressed: _toggleNumberedList,
                  tooltip: 'Numbered List',
                ),

                const VerticalDivider(width: 1),

                // Media
                _buildToolbarButton(
                  icon: Icons.link,
                  isActive: _isLink,
                  onPressed: _insertLink,
                  tooltip: 'Insert Link',
                ),
                _buildToolbarButton(
                  icon: Icons.image,
                  isActive: _isImage,
                  onPressed: _insertImage,
                  tooltip: 'Insert Image',
                ),
                _buildToolbarButton(
                  icon: Icons.video_library,
                  isActive: _isVideo,
                  onPressed: _insertVideo,
                  tooltip: 'Insert Video',
                ),

                const VerticalDivider(width: 1),

                // Alignment
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  onPressed: () {},
                  tooltip: 'Align Left',
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  onPressed: () {},
                  tooltip: 'Align Center',
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  onPressed: () {},
                  tooltip: 'Align Right',
                ),

                const VerticalDivider(width: 1),

                // Clear formatting
                _buildToolbarButton(
                  icon: Icons.format_clear,
                  onPressed: () {
                    setState(() {
                      _isBold = false;
                      _isItalic = false;
                      _isUnderline = false;
                      _isBulletList = false;
                      _isNumberedList = false;
                    });
                  },
                  tooltip: 'Clear Formatting',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Editor
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Write your content here...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: isActive ? Colors.blue : Colors.grey[700],
      tooltip: tooltip,
      iconSize: 20,
    );
  }
}