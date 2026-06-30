import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import '../user/user_home_screen.dart';
import '../expert/expert_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _selectedState;
  String? _selectedDistrict;
  List<String> _states = [];
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    try {
      final statesData = await FirestoreService.loadStates();
      if (mounted) {
        setState(() {
          _states = statesData.map((s) => s['name'] ?? s.toString()).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadDistricts(String state) async {
    try {
      final statesData = await FirestoreService.loadStates();
      if (mounted) {
        final found = statesData.firstWhere(
          (s) => (s['name'] ?? '').toString().toLowerCase() == state.toLowerCase(),
          orElse: () => {},
        );
        setState(() {
          _districts = (found['districts'] is List)
              ? (found['districts'] as List).map((d) => d.toString()).toList()
              : [];
        });
      }
    } catch (_) {}
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        'state': _selectedState ?? '',
        'district': _selectedDistrict ?? '',
        'address': _addressController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'userId': generateId(),
      };
      final success = await context.read<AuthProvider>().register(
        _emailController.text.trim(),
        _passwordController.text,
        widget.role,
        profileData,
      );
      if (!mounted) return;
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                widget.role == 'expert'
                    ? const ExpertHomeScreen()
                    : const UserHomeScreen(),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    setState(() => _currentStep = 1);
  }

  @override
  Widget build(BuildContext context) {
    final isExpert = widget.role == 'expert';
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 18, color: AppTheme.textDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: _currentStep == 0
                      ? _buildStep1(isExpert)
                      : _buildStep2(isExpert),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _StepDot(active: _currentStep >= 0, label: 'Personal'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep >= 1 ? AppTheme.primary : Colors.grey[300],
            ),
          ),
          _StepDot(active: _currentStep >= 1, label: 'Details'),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isExpert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Signing up as ${isExpert ? 'Expert' : 'User'}',
          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your name';
            if (v.trim().length < 2) return 'Name is too short';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email', prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your email';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '10-digit number',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your phone number';
            final digits = v.replaceAll(RegExp(r'\D'), '');
            if (digits.length != 10) return 'Enter a valid 10-digit number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter a password';
            if (v.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('Next', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600,
            )),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2(bool isExpert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Help us find services near you',
          style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _selectedState,
          decoration: const InputDecoration(
            labelText: 'State', prefixIcon: Icon(Icons.map_outlined),
          ),
          items: _states.map((s) {
            return DropdownMenuItem(value: s, child: Text(s));
          }).toList(),
          onChanged: (v) {
            setState(() {
              _selectedState = v;
              _selectedDistrict = null;
              _districts = [];
            });
            if (v != null) _loadDistricts(v);
          },
          validator: (v) => v == null ? 'Select a state' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: const InputDecoration(
            labelText: 'District', prefixIcon: Icon(Icons.location_city_outlined),
          ),
          items: _districts.map((d) {
            return DropdownMenuItem(value: d, child: Text(d));
          }).toList(),
          onChanged: (v) => setState(() => _selectedDistrict = v),
          validator: (v) => v == null ? 'Select a district' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Full Address',
            prefixIcon: Icon(Icons.home_outlined),
            alignLabelWithHint: true,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your address';
            if (v.trim().length < 5) return 'Enter a complete address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _landmarkController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Landmark (optional)',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pincodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Pincode',
            prefixIcon: Icon(Icons.local_post_office_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter pincode';
            if (v.trim().length < 6) return 'Enter a valid 6-digit pincode';
            return null;
          },
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                  child: Text('Back', style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primary,
                  )),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.role == 'expert' ? 'Register as Expert' : 'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            active ? Icons.check : Icons.circle_outlined,
            color: Colors.white, size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: active ? AppTheme.primary : Colors.grey[500],
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
