import 'package:flutter/material.dart';

class MediaUploader extends StatefulWidget {
  final String? featuredImage;
  final List<String> imageGallery;
  final ValueChanged<String?> onFeaturedImageChanged;
  final ValueChanged<List<String>> onImageGalleryChanged;

  const MediaUploader({
    super.key,
    this.featuredImage,
    required this.imageGallery,
    required this.onFeaturedImageChanged,
    required this.onImageGalleryChanged,
  });

  @override
  State<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends State<MediaUploader> {
  final List<String> _uploadedImages = [];

  Future<void> _pickFeaturedImage() async {
    // In a real app, this would open an image picker
    // For now, we'll simulate with a placeholder
    widget.onFeaturedImageChanged('https://via.placeholder.com/800x400');
  }

  Future<void> _pickGalleryImages() async {
    // In a real app, this would open a multi-image picker
    // For now, we'll simulate with placeholder images
    final newImages = [
      'https://via.placeholder.com/400x300',
      'https://via.placeholder.com/400x300/007bff',
      'https://via.placeholder.com/400x300/28a745',
    ];

    widget.onImageGalleryChanged([...widget.imageGallery, ...newImages]);
  }

  void _removeFeaturedImage() {
    widget.onFeaturedImageChanged(null);
  }

  void _removeGalleryImage(int index) {
    final newGallery = List<String>.from(widget.imageGallery);
    newGallery.removeAt(index);
    widget.onImageGalleryChanged(newGallery);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Image Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.featuredImage != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.featuredImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _removeFeaturedImage,
                        icon: const Icon(Icons.close, size: 20),
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Featured Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickFeaturedImage,
                      icon: const Icon(Icons.upload),
                      label: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Image Gallery Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Image Gallery',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.imageGallery.length} images',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.imageGallery.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: widget.imageGallery.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.imageGallery[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeGalleryImage(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: TextButton.icon(
                onPressed: _pickGalleryImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images to Gallery'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Upload Progress (simulated)
        if (_uploadedImages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uploading...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.7, // Simulated progress
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
      ],
    );
  }
}