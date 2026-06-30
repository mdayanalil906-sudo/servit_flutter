import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firestore_service.dart';
import 'package:servit_flutter/services/storage_service.dart';

class ExpertEditProfileScreen extends StatefulWidget {
  const ExpertEditProfileScreen({super.key});

  @override
  State<ExpertEditProfileScreen> createState() =>
      _ExpertEditProfileScreenState();
}

class _ExpertEditProfileScreenState extends State<ExpertEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategory = '';
  File? _photoFile;
  bool _isUploading = false;
  String? _photoUrl;

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'AC Repair',
    'Appliance Repair',
    'Pest Control',
    'Gardening',
    'Moving & Packing',
    'Home Renovation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert != null) {
        _nameController.text = expert.name;
        _phoneController.text = expert.phone;
        _priceMinController.text =
            expert.priceMin > 0 ? expert.priceMin.toStringAsFixed(0) : '';
        _priceMaxController.text =
            expert.priceMax > 0 ? expert.priceMax.toStringAsFixed(0) : '';
        _descriptionController.text = expert.description;
        _experienceController.text = expert.experience;
        _stateController.text = expert.state;
        _districtController.text = expert.district;
        _addressController.text = expert.address;
        _selectedCategory = expert.category;
        _photoUrl = expert.profilePhoto;
      }
    });
  }

  Future<void> _pickPhoto() async {
    final picked = await StorageService.pickImage();
    if (picked != null) {
      setState(() {
        _photoFile = File(picked.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;

      String? photoUrl = _photoUrl;
      if (_photoFile != null) {
        photoUrl = await StorageService.uploadFile(
          _photoFile!,
          'profile_photos/${expert.uid}/profile.${_photoFile!.path.split('.').last}',
        );
      }

      await FirestoreService.updateExpertProfile(expert.uid, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'priceMin': double.tryParse(_priceMinController.text) ?? 0,
        'priceMax': double.tryParse(_priceMaxController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'experience': _experienceController.text.trim(),
        'state': _stateController.text.trim(),
        'district': _districtController.text.trim(),
        'address': _addressController.text.trim(),
        if (photoUrl != null) 'profilePhoto': photoUrl,
      });

      await auth.loadExpertProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _save,
            child: _isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.nunito(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.1),
                      backgroundImage: _photoFile != null
                          ? FileImage(_photoFile!)
                          : (_photoUrl != null && _photoUrl!.isNotEmpty
                              ? NetworkImage(_photoUrl!)
                              : null),
                      child: _photoFile == null &&
                              (_photoUrl == null || _photoUrl!.isEmpty)
                          ? Icon(Icons.person_rounded,
                              size: 48, color: AppTheme.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField('Full Name', _nameController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              _buildField('Phone Number', _phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.nunito(
                      fontSize: 14, color: Colors.grey),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? ''),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select a category' : null,
                style: GoogleFonts.nunito(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Min Price (₹)', _priceMinController,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Max Price (₹)', _priceMaxController,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildField('Description', _descriptionController,
                  maxLines: 3),
              const SizedBox(height: 14),
              _buildField('Experience (years)', _experienceController),
              const SizedBox(height: 14),
              _buildField('State', _stateController),
              const SizedBox(height: 14),
              _buildField('District', _districtController),
              const SizedBox(height: 14),
              _buildField('Address', _addressController, maxLines: 2),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.nunito(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
