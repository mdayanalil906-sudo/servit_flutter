import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firebase_service.dart';
import 'package:servit_flutter/services/storage_service.dart';

class ExpertWorkPhotosScreen extends StatefulWidget {
  const ExpertWorkPhotosScreen({super.key});

  @override
  State<ExpertWorkPhotosScreen> createState() =>
      _ExpertWorkPhotosScreenState();
}

class _ExpertWorkPhotosScreenState extends State<ExpertWorkPhotosScreen> {
  List<String> _photos = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;
      final data = await FirebaseService.getDocument('experts', expert.uid);
      if (data != null && data['workPhotos'] != null) {
        _photos = List<String>.from(data['workPhotos']);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _addPhoto() async {
    final picked = await StorageService.pickImage();
    if (picked == null) return;
    setState(() => _isUploading = true);
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;
      final file = File(picked.path);
      final ext = file.path.split('.').last;
      final url = await StorageService.uploadFile(
        file,
        'work_photos/${expert.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      _photos.add(url);
      await FirebaseService.setDocument('experts', expert.uid, {
        'workPhotos': _photos,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading photo: $e'),
            backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Photo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;
      _photos.removeAt(index);
      await FirebaseService.setDocument('experts', expert.uid, {
        'workPhotos': _photos,
      });
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting photo'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Work Photos'),
        actions: [
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
              ),
            )
          else
            IconButton(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_photo_alternate_rounded),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No work photos yet',
                        style: GoogleFonts.nunito(
                            fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add photos of your work',
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPhotos,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: _photos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () => _deletePhoto(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _photos[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: isDark
                                        ? AppTheme.cardDark
                                        : Colors.grey[200],
                                    child: Icon(Icons.broken_image_rounded,
                                        color: Colors.grey[400]),
                                  ),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: isDark
                                          ? AppTheme.cardDark
                                          : Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes !=
                                                  null
                                              ? progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _deletePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error
                                            .withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded,
                                          size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
