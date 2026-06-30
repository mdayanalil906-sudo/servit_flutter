import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/search_provider.dart';
import '../../models/expert.dart';
import '../../widgets/expert_card.dart';
import '../../widgets/empty_state.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final Set<String> _activeFilters = {};
  RangeValues _priceRange = const RangeValues(0, 50000);

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Cleaning',
    'Painting',
    'Gardening',
    'AC Repair',
    'Pest Control',
    'Moving',
    'Tutoring',
    'Photography',
    'Design',
  ];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      await context.read<SearchProvider>().search(
            query: widget.query,
            categoryFilter: _activeFilters.intersection(_categories.toSet()).join(','),
            stateFilter: _activeFilters.where((f) => !_categories.contains(f)).join(','),
            minPrice: _priceRange.start.toInt(),
            maxPrice: _priceRange.end.toInt(),
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.query,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Verified',
                  selected: _activeFilters.contains('verified'),
                  onSelected: (v) => _toggleFilter('verified'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Premium',
                  selected: _activeFilters.contains('premium'),
                  onSelected: (v) => _toggleFilter('premium'),
                ),
                const SizedBox(width: 8),
                ..._categories.take(4).map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: cat,
                      selected: _activeFilters.contains(cat),
                      onSelected: (v) => _toggleFilter(cat),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Price Range',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 50000,
                    divisions: 50,
                    activeColor: AppTheme.primary,
                    labels: RangeLabels(
                      '₹${_priceRange.start.toInt()}',
                      '₹${_priceRange.end.toInt()}',
                    ),
                    onChanged: (v) => setState(() => _priceRange = v),
                    onChangeEnd: (_) => _performSearch(),
                  ),
                ),
                Text(
                  '₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
    _performSearch();
  }

  Widget _buildResultsList() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = searchProvider.results;

        if (results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            message: 'No experts found for "${widget.query}"',
            subtitle: 'Try adjusting your filters or search terms',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final expert = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpertCard(
                expert: expert,
                onTap: () {
                  Navigator.pushNamed(context, '/expert-detail',
                      arguments: expert);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
