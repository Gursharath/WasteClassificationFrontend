import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;

  const ResultScreen({super.key, required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  String? label;
  double? confidence;
  bool isLoading = true;
  String? errorMessage;
  String apiUrl = 'http://192.168.1.30:5000/predict';

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _classifyImage();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _progressController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _classifyImage() async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('image', widget.imageFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final result = jsonDecode(await response.stream.bytesToString());
        setState(() {
          label = result['label'];
          confidence = result['confidence'];
          isLoading = false;
        });

        // Trigger success animations
        _scaleController.forward();
        _slideController.forward();
        _progressController.stop();

        _saveToHistory();
        HapticFeedback.lightImpact();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to classify image. Please try again.';
        });
        _progressController.stop();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Network error. Please check your connection.';
      });
      _progressController.stop();
    }
  }

  void _saveToHistory() async {
    final box = Hive.box('predictions');
    final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    await box.add({
      'label': label,
      'confidence': confidence,
      'timestamp': timestamp,
      'path': widget.imageFile.path,
    });
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return const Color(0xFF00D4AA);
    if (confidence >= 60) return const Color(0xFFFFB800);
    return const Color(0xFFFF6B6B);
  }

  String _getWasteCategory(String? label) {
    if (label == null) return 'Unknown';
    // Add your waste category logic here
    final categories = {
      'plastic': 'Recyclable',
      'glass': 'Recyclable',
      'metal': 'Recyclable',
      'paper': 'Recyclable',
      'organic': 'Compostable',
      'hazardous': 'Special Disposal',
    };

    for (var key in categories.keys) {
      if (label.toLowerCase().contains(key)) {
        return categories[key]!;
      }
    }
    return 'General Waste';
  }

  Widget _buildLoadingScreen() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      const Color(0xFF00D4AA).withOpacity(0.1),
                      const Color(0xFF00D4AA),
                      const Color(0xFF01A085),
                      const Color(0xFF00D4AA).withOpacity(0.1),
                    ],
                    stops: [
                      0.0,
                      _progressAnimation.value,
                      _progressAnimation.value,
                      1.0,
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A2E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Color(0xFF00D4AA),
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            'Analyzing Image...',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Our AI is processing your image\nto identify waste category',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: _getConfidenceColor(confidence ?? 0).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Classification Result
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(confidence ?? 0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.label,
                  color: _getConfidenceColor(confidence ?? 0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classification',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label?.toUpperCase() ?? 'UNKNOWN',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Confidence Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: _getConfidenceColor(confidence ?? 0),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Confidence: ',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${confidence?.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(confidence ?? 0),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (confidence ?? 0) / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidence ?? 0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.category, color: const Color(0xFF00D4AA), size: 20),
                const SizedBox(width: 12),
                Text(
                  'Category: ',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getWasteCategory(label),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00D4AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Retry Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _progressController.repeat();
              _classifyImage();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Analyze Again',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
          ),
        ),

        // Save/Share Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implement save functionality
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Result saved to history'),
                      backgroundColor: const Color(0xFF00D4AA),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(Icons.save, color: Colors.white.withOpacity(0.8)),
                label: Text(
                  'Save',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implement share functionality
                  HapticFeedback.lightImpact();
                },
                icon: Icon(Icons.share, color: Colors.white.withOpacity(0.8)),
                label: Text(
                  'Share',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Classification Result',
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            isLoading
                ? _buildLoadingScreen()
                : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Image Display
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    widget.imageFile,
                                    height: 280,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Results or Error
                          if (errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (label != null)
                            SlideTransition(
                              position: _slideAnimation,
                              child: _buildResultCard(),
                            ),

                          const SizedBox(height: 30),

                          // Action Buttons
                          _buildActionButtons(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}
