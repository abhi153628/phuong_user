import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const neonGreen = AppColors.activeGreen;
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkSurface,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.syne(
            color: white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildUpdatedDate(),
                  const SizedBox(height: 24),
                  _buildIntroduction(),
                  ..._buildSections(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatedDate() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      )),
      child: Text(
        'Last Updated: January 3, 2025',
        style: GoogleFonts.notoSans(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 1, curve: Curves.easeOut),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: neonGreen.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: neonGreen.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Introduction',
              style: GoogleFonts.syne(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: neonGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to Phuong. We are committed to protecting your privacy and ensuring the security of your personal information.',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Information We Collect',
        'content': [
          {
            'title': 'User-Provided Information',
            'items': <String>[
              'Account information',
              'Profile information',
              'Authentication credentials',
              'Payment information',
              'Communications',
              'Event booking details',
            ],
          },
          {
            'title': 'Automatically Collected Information',
            'items': <String>[
              'Device information',
              'Location data',
              'Usage data',
              'IP address',
              'App performance data',
            ],
          },
          
        ],
      },
      {
        'title': 'How We Use Your Information',
        'content': <String>[
          'Provide and maintain our services',
          'Process event bookings and payments',
          'Enable communication between users',
          'Send push notifications',
          'Authenticate users',
        ],
      },
      {
        'title': 'Data Security',
        'content': <String>[
          'End-to-end encryption for sensitive data',
          'Regular security audits',
          'Secure payment processing',
          'Protected user authentication',
          'Continuous monitoring',
        ],
      },
    ];

    return sections.map((section) {
      return _buildExpandableSection(
        section['title'] as String,
        section['content'] as List<dynamic>,
      );
    }).toList();
  }

  Widget _buildExpandableSection(String title, List<dynamic> content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonGreen.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData.dark().copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: neonGreen,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content.map((item) {
                  if (item is Map<String, dynamic>) {
                    return _buildSubSection(
                      item['title'] as String,
                      item['items'] as List<String>,
                    );
                  } else {
                    return _buildListItem(item.toString());
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: neonGreen.withOpacity(0.8),
            ),
          ),
        ),
        ...items.map(_buildListItem).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: neonGreen.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonGreen.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: neonGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'If you have any questions or concerns about this Privacy Policy, please contact us at support@phuong.com',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}