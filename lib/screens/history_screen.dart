import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late Box box;
  String filter = "All";
  bool isGridView = false;

  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;

  final List<String> filterOptions = [
    "All",
    "Organic",
    "Recyclable",
    "Plastic",
    "Glass",
    "Metal",
    "Paper",
    "Hazardous",
  ];

  @override
  void initState() {
    super.initState();
    box = Hive.box('predictions');
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String label) {
    final colors = {
      'organic': const Color(0xFF4CAF50),
      'recyclable': const Color(0xFF2196F3),
      'plastic': const Color(0xFF9C27B0),
      'glass': const Color(0xFF00BCD4),
      'metal': const Color(0xFF607D8B),
      'paper': const Color(0xFF795548),
      'hazardous': const Color(0xFFFF5722),
    };

    for (var key in colors.keys) {
      if (label.toLowerCase().contains(key)) {
        return colors[key]!;
      }
    }
    return const Color(0xFF00D4AA);
  }

  IconData _getCategoryIcon(String label) {
    final icons = {
      'organic': Icons.eco,
      'recyclable': Icons.recycling,
      'plastic': Icons.opacity,
      'glass': Icons.wine_bar,
      'metal': Icons.build,
      'paper': Icons.description,
      'hazardous': Icons.warning,
    };

    for (var key in icons.keys) {
      if (label.toLowerCase().contains(key)) {
        return icons[key]!;
      }
    }
    return Icons.category;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Category',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          filterOptions.map((option) {
                            final isSelected = filter == option;
                            return InkWell(
                              onTap: () {
                                setState(() => filter = option);
                                Navigator.pop(context);
                                HapticFeedback.lightImpact();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF00D4AA)
                                          : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF00D4AA)
                                            : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: GoogleFonts.inter(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.8),
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteItem(int index, Map item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Item',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this classification?',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final items = box.values.cast<Map>().toList();
                  final actualIndex = items.length - 1 - index;
                  box.deleteAt(actualIndex);
                  setState(() {});
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item deleted'),
                      backgroundColor: const Color(0xFF00D4AA),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHistoryCard(Map item, int index) {
    final categoryColor = _getCategoryColor(item['label']);
    final categoryIcon = _getCategoryIcon(item['label']);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Ensure value is always within bounds
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: 0.8 + (0.2 * clampedValue),
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Show detailed view
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Image
                      Hero(
                        tag: 'image_${item['path']}_$index',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(item['path']),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white.withOpacity(0.1),
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    categoryIcon,
                                    size: 16,
                                    color: categoryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['label'].toString().toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Confidence: ${item['confidence']?.toStringAsFixed(1)}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item['timestamp'].toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: const Color(0xFFFF6B6B),
                                size: 18,
                              ),
                              onPressed: () => _deleteItem(index, item),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.history,
              size: 50,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            filter == "All" ? "No History Found" : "No ${filter} Items",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filter == "All"
                ? "Start classifying waste to see your history here"
                : "No items found for the selected filter",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          if (filter != "All")
            ElevatedButton.icon(
              onPressed: () => setState(() => filter = "All"),
              icon: const Icon(Icons.clear, color: Colors.white),
              label: Text(
                'Clear Filter',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = box.values.cast<Map>().toList().reversed.toList();
    final filtered =
        filter == "All"
            ? items
            : items
                .where(
                  (e) => e['label'].toString().toLowerCase().contains(
                    filter.toLowerCase(),
                  ),
                )
                .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Classification History',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Filter indicator
                if (filter != "All")
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00D4AA).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: const Color(0xFF00D4AA),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtered by: $filter',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => filter = "All"),
                          child: Icon(
                            Icons.close,
                            color: const Color(0xFF00D4AA),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Results count
                if (filtered.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'} found',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child:
                      filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                            itemCount: filtered.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _buildHistoryCard(filtered[index], index);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
