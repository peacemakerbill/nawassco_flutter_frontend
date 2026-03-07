// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:photo_view/photo_view.dart';
//
// class ImagePickerWidget extends StatefulWidget {
//   final Function(List<XFile>) onImagesSelected;
//   final int? maxImages;
//   final double? imageSize;
//   final bool allowCamera;
//   bool allowGallery;
//   final String? label;
//   final String? hintText;
//   final bool showPreview;
//   final double? aspectRatio;
//   final int? maxWidth;
//   final int? maxHeight;
//   final int imageQuality;
//   final bool allowMultiple;
//   final bool showImageInfo;
//
//   ImagePickerWidget({
//     super.key,
//     required this.onImagesSelected,
//     this.maxImages,
//     this.imageSize = 100,
//     this.allowCamera = true,
//     this.allowGallery = true,
//     this.label,
//     this.hintText,
//     this.showPreview = true,
//     this.aspectRatio,
//     this.maxWidth,
//     this.maxHeight,
//     this.imageQuality = 85,
//     this.allowMultiple = true,
//     this.showImageInfo = true,
//   });
//
//   @override
//   State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
// }
//
// class _ImagePickerWidgetState extends State<ImagePickerWidget> {
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _selectedImages = [];
//   bool _isLoading = false;
//   int _currentPreviewIndex = 0;
//
//   Future<void> _pickImages(ImageSource source) async {
//     if (widget.maxImages != null && _selectedImages.length >= widget.maxImages!) {
//       _showSnackBar('Maximum ${widget.maxImages} images allowed', isError: true);
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final List<XFile> pickedImages;
//
//       if (source == ImageSource.camera) {
//         // Single image from camera
//         final image = await _picker.pickImage(
//           source: source,
//           maxWidth: widget.maxWidth?.toDouble(),
//           maxHeight: widget.maxHeight?.toDouble(),
//           imageQuality: widget.imageQuality,
//           preferredCameraDevice: CameraDevice.rear,
//         );
//
//         if (image != null) {
//           pickedImages = [image];
//         } else {
//           pickedImages = [];
//         }
//       } else {
//         // Multiple images from gallery
//         pickedImages = await _picker.pickMultiImage(
//           imageQuality: widget.imageQuality,
//         );
//       }
//
//       if (pickedImages.isNotEmpty) {
//         final availableSlots = widget.maxImages != null
//             ? widget.maxImages! - _selectedImages.length
//             : pickedImages.length;
//
//         final imagesToAdd = pickedImages.take(availableSlots).toList();
//
//         setState(() {
//           _selectedImages.addAll(imagesToAdd);
//         });
//
//         widget.onImagesSelected(_selectedImages);
//
//         if (imagesToAdd.length < pickedImages.length) {
//           _showSnackBar('Added ${imagesToAdd.length} images (max limit reached)', isError: false);
//         }
//       }
//     } catch (e) {
//       _showSnackBar('Failed to pick images: ${e.toString()}', isError: true);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//       if (_currentPreviewIndex >= _selectedImages.length) {
//         _currentPreviewIndex = _selectedImages.length - 1;
//       }
//     });
//     widget.onImagesSelected(_selectedImages);
//   }
//
//   void _clearAll() {
//     setState(() {
//       _selectedImages.clear();
//       _currentPreviewIndex = 0;
//     });
//     widget.onImagesSelected(_selectedImages);
//   }
//
//   void _showSourceSelector() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => _buildSourceSelector(),
//     );
//   }
//
//   Widget _buildSourceSelector() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Drag Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12, bottom: 8),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//
//             // Header
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Row(
//                 children: [
//                   const Icon(Iconsax.gallery_add, color: Colors.blue, size: 24),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Select Images',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   if (_selectedImages.isNotEmpty)
//                     Text(
//                       '(${_selectedImages.length} selected)',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             // Source Options
//             if (widget.allowCamera && widget.allowGallery)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: _SourceButton(
//                         icon: Iconsax.camera,
//                         label: 'Camera',
//                         color: Colors.blue,
//                         onTap: () {
//                           Navigator.pop(context);
//                           _pickImages(ImageSource.camera);
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _SourceButton(
//                         icon: Iconsax.gallery,
//                         label: 'Gallery',
//                         color: Colors.purple,
//                         onTap: () {
//                           Navigator.pop(context);
//                           _pickImages(ImageSource.gallery);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             else if (widget.allowCamera)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: _SourceButton(
//                   icon: Iconsax.camera,
//                   label: 'Take Photo',
//                   color: Colors.blue,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImages(ImageSource.camera);
//                   },
//                 ),
//               )
//             else if (widget.allowGallery)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: _SourceButton(
//                     icon: Iconsax.gallery,
//                     label: 'Choose from Gallery',
//                     color: Colors.purple,
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImages(ImageSource.gallery);
//                     },
//                   ),
//                 ),
//
//             // Image Stats
//             if (widget.maxImages != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Iconsax.info_circle, size: 16, color: Colors.grey),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           '${_selectedImages.length} of ${widget.maxImages} images selected',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showImagePreview(int index) {
//     if (!widget.showPreview) return;
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.zero,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 0.95,
//           height: MediaQuery.of(context).size.height * 0.85,
//           child: _buildImagePreview(index),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImagePreview(int index) {
//     final image = _selectedImages[index];
//
//     return Stack(
//       children: [
//         // Image Viewer
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: PhotoView(
//             imageProvider: FileImage(File(image.path)),
//             backgroundDecoration: const BoxDecoration(color: Colors.black),
//             minScale: PhotoViewComputedScale.contained,
//             maxScale: PhotoViewComputedScale.covered * 3,
//             heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
//             loadingBuilder: (context, event) => Center(
//               child: CircularProgressIndicator(
//                 value: event == null
//                     ? 0
//                     : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
//               ),
//             ),
//           ),
//         ),
//
//         // Top Bar
//         Positioned(
//           top: 16,
//           left: 16,
//           right: 16,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: 0.7),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Iconsax.close_circle, color: Colors.white),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         image.name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       FutureBuilder<File>(
//                         future: File(image.path).exists().then((exists) => exists ? File(image.path) : null),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             final file = snapshot.data!;
//                             return FutureBuilder<int>(
//                               future: file.length(),
//                               builder: (context, sizeSnapshot) {
//                                 if (sizeSnapshot.hasData) {
//                                   final size = sizeSnapshot.data!;
//                                   return Text(
//                                     '${_formatBytes(size)} • ${_getImageDimensions(file)}',
//                                     style: const TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 11,
//                                     ),
//                                   );
//                                 }
//                                 return const SizedBox();
//                               },
//                             );
//                           }
//                           return const SizedBox();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         // Bottom Navigation (if multiple images)
//         if (_selectedImages.length > 1)
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.7),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: index > 0
//                         ? () {
//                       Navigator.pop(context);
//                       _showImagePreview(index - 1);
//                     }
//                         : null,
//                     icon: Icon(
//                       Iconsax.arrow_left_2,
//                       color: index > 0 ? Colors.white : Colors.white30,
//                     ),
//                   ),
//                   Text(
//                     '${index + 1} / ${_selectedImages.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: index < _selectedImages.length - 1
//                         ? () {
//                       Navigator.pop(context);
//                       _showImagePreview(index + 1);
//                     }
//                         : null,
//                     icon: Icon(
//                       Iconsax.arrow_right_3,
//                       color: index < _selectedImages.length - 1 ? Colors.white : Colors.white30,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError ? Iconsax.warning_2 : Iconsax.info_circle,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   String _formatBytes(int bytes) {
//     if (bytes <= 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB'];
//     final i = (log(bytes) / log(1024)).floor();
//     return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
//   }
//
//   Future<String> _getImageDimensions(File file) async {
//     try {
//       final bytes = await file.readAsBytes();
//       final image = await decodeImageFromList(bytes);
//       return '${image.width}×${image.height}';
//     } catch (e) {
//       return 'Unknown dimensions';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label
//         if (widget.label != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Row(
//               children: [
//                 Text(
//                   widget.label!,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 if (widget.maxImages != null)
//                   Text(
//                     ' (max ${widget.maxImages})',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 const Spacer(),
//                 if (_selectedImages.isNotEmpty)
//                   TextButton(
//                     onPressed: _clearAll,
//                     child: const Text(
//                       'Clear All',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.red,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//         // Main Container
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _selectedImages.isEmpty
//                   ? Colors.grey[300]!
//                   : Colors.blue.withValues(alpha: 0.3),
//               width: 2,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             color: Colors.white,
//           ),
//           child: Column(
//             children: [
//               // Image Grid
//               if (_selectedImages.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: _buildImageGrid(),
//                 ),
//
//               // Add Button Area
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(_selectedImages.isEmpty ? 16 : 0),
//                     bottomRight: Radius.circular(_selectedImages.isEmpty ? 16 : 0),
//                   ),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: _showSourceSelector,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(_selectedImages.isEmpty ? 16 : 0),
//                       bottomRight: Radius.circular(_selectedImages.isEmpty ? 16 : 0),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(_selectedImages.isEmpty ? 32 : 20),
//                       child: Column(
//                         children: [
//                           if (_isLoading)
//                             const CircularProgressIndicator()
//                           else
//                             Icon(
//                               _selectedImages.isEmpty
//                                   ? Iconsax.gallery_add
//                                   : Iconsax.add_circle,
//                               size: _selectedImages.isEmpty ? 48 : 32,
//                               color: Colors.blue.withValues(alpha: 0.7),
//                             ),
//                           const SizedBox(height: 12),
//                           Text(
//                             _selectedImages.isEmpty
//                                 ? widget.hintText ?? 'Add Images'
//                                 : 'Add More Images',
//                             style: TextStyle(
//                               fontSize: _selectedImages.isEmpty ? 16 : 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _getSourceDescription(),
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Image Info
//         if (widget.showImageInfo && _selectedImages.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withValues(alpha: 0.05),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Iconsax.info_circle, size: 16, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} selected',
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: Colors.blue,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         FutureBuilder<void>(
//                           future: _calculateTotalSize(),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.done) {
//                               final totalSize = _selectedImages.fold<int>(
//                                 0,
//                                     (sum, image) => sum + (File(image.path).lengthSync()),
//                               );
//                               return Text(
//                                 'Total size: ${_formatBytes(totalSize)}',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               );
//                             }
//                             return const SizedBox();
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildImageGrid() {
//     final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 3;
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1,
//       ),
//       itemCount: _selectedImages.length,
//       itemBuilder: (context, index) {
//         final image = _selectedImages[index];
//         return _ImageItem(
//           image: image,
//           index: index,
//           onTap: () => _showImagePreview(index),
//           onRemove: () => _removeImage(index),
//           isSelected: index == _currentPreviewIndex,
//         );
//       },
//     );
//   }
//
//   String _getSourceDescription() {
//     if (widget.allowCamera && widget.allowGallery) {
//       return 'Tap to use camera or select from gallery';
//     } else if (widget.allowCamera) {
//       return 'Tap to take a photo with camera';
//     } else if (widget.allowGallery) {
//       return 'Tap to select images from gallery';
//     }
//     return 'Image selection is disabled';
//   }
//
//   Future<void> _calculateTotalSize() async {
//     // Just triggers the async calculation
//     await Future.delayed(Duration.zero);
//   }
// }
//
// class _ImageItem extends StatelessWidget {
//   final XFile image;
//   final int index;
//   final VoidCallback onTap;
//   final VoidCallback onRemove;
//   final bool isSelected;
//
//   const _ImageItem({
//     required this.image,
//     required this.index,
//     required this.onTap,
//     required this.onRemove,
//     required this.isSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         children: [
//           // Image Container
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//               border: Border.all(
//                 color: isSelected ? Colors.blue : Colors.transparent,
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: FutureBuilder<bool>(
//                 future: File(image.path).exists(),
//                 builder: (context, snapshot) {
//                   if (snapshot.data == true) {
//                     return Image.file(
//                       File(image.path),
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
//                     );
//                   }
//                   return _buildErrorPlaceholder();
//                 },
//               ),
//             ),
//           ),
//
//           // Selection Badge
//           if (isSelected)
//             Positioned(
//               top: 4,
//               right: 4,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Iconsax.tick_circle,
//                   size: 12,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//
//           // Remove Button
//           Positioned(
//             top: 4,
//             left: 4,
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 2,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: IconButton(
//                 onPressed: onRemove,
//                 icon: const Icon(
//                   Iconsax.close_circle,
//                   size: 16,
//                   color: Colors.red,
//                 ),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 tooltip: 'Remove',
//               ),
//             ),
//           ),
//
//           // Image Number
//           Positioned(
//             bottom: 4,
//             left: 4,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.6),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '${index + 1}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorPlaceholder() {
//     return Container(
//       color: Colors.grey[100],
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Iconsax.gallery_remove, color: Colors.grey, size: 24),
//             SizedBox(height: 4),
//             Text(
//               'Failed to load',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 9,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SourceButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _SourceButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color.withValues(alpha: 0.3)),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 32, color: color),
//               const SizedBox(height: 12),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Tap to select',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: color.withValues(alpha: 0.7),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }