import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(imageFile: image)),
      );
    }
  }

  Widget _buildProfessionalButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (delay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
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

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00D4AA), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header - Fixed height
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00D4AA),
                    Color(0xFF01A085),
                    Color(0xFF016B5A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4AA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.recycling,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "WasteClassify Pro",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "AI-Powered Smart Waste Management",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "94% Accuracy",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  // Enhanced Menu Items
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    title: "Home",
                    subtitle: "Dashboard & Quick Actions",
                    isActive: true,
                    onTap: () => Navigator.pop(context),
                    gradientColors: [Color(0xFF00D4AA), Color(0xFF01A085)],
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: "Classification History",
                    subtitle: "View past scans & results",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/history");
                    },
                    gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    title: "Analytics Dashboard",
                    subtitle: "Insights & statistics",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/charts");
                    },
                    gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.eco_outlined,
                    activeIcon: Icons.eco,
                    title: "Eco Tips",
                    subtitle: "Sustainable living guide",
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation to eco tips screen
                    },
                    gradientColors: [Color(0xFF56ab2f), Color(0xFFa8e6cf)],
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: "Settings",
                    subtitle: "App preferences & config",
                    onTap: () {
                      Navigator.pop(context);
                      // Add navigation to settings screen
                    },
                    gradientColors: [Color(0xFF8360c3), Color(0xFF2ebf91)],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4AA).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Color(0xFF00D4AA),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Version 2.1.0",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Latest update available",
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient:
                  isActive
                      ? LinearGradient(
                        colors:
                            gradientColors
                                .map((c) => c.withOpacity(0.2))
                                .toList(),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                      : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isActive
                        ? gradientColors.first.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isActive
                              ? gradientColors
                              : [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isActive
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color:
                        isActive ? Colors.white : Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color:
                              isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(isActive ? 0.8 : 0.4),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      drawer: _buildAppDrawer(context), // Drawer added here
      appBar: AppBar(
        title: Text(
          "WasteClassify Pro",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: Colors.white,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4AA).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00D4AA).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.recycling,
                              size: 50,
                              color: Color(0xFF00D4AA),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "AI-Powered Waste\nClassification",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Upload or capture images to identify waste categories\nand get proper disposal recommendations",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        _buildStatsCard(
                          "Scanned",
                          "247",
                          Icons.camera_alt_outlined,
                        ),
                        const SizedBox(width: 16),
                        _buildStatsCard(
                          "Accuracy",
                          "94%",
                          Icons.verified_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Quick Actions",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfessionalButton(
                      icon: Icons.photo_library_outlined,
                      label: "Import from Gallery",
                      subtitle: "Select an image from your device",
                      onPressed: () => _pickImage(ImageSource.gallery),
                      gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      delay: 0,
                    ),
                    _buildProfessionalButton(
                      icon: Icons.camera_alt_outlined,
                      label: "Capture Photo",
                      subtitle: "Take a new photo for classification",
                      onPressed: () => _pickImage(ImageSource.camera),
                      gradientColors: [Color(0xFF00D4AA), Color(0xFF01A085)],
                      delay: 1,
                    ),
                    _buildProfessionalButton(
                      icon: Icons.history_outlined,
                      label: "Classification History",
                      subtitle: "View your previous classifications",
                      onPressed: () => Navigator.pushNamed(context, "/history"),
                      gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                      delay: 2,
                    ),
                    _buildProfessionalButton(
                      icon: Icons.analytics_outlined,
                      label: "Analytics Dashboard",
                      subtitle: "View detailed charts and insights",
                      onPressed: () => Navigator.pushNamed(context, "/charts"),
                      gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                      delay: 3,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
