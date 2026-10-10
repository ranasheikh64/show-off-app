import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C1F),
        elevation: 0,
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.support_agent_rounded,
                size: 80.sp,
                color: const Color(0xFF007BFF),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Find answers to common questions or reach out to our team.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 32.h),
            _buildFAQItem(
              question: 'How do I change my password?',
              answer: 'You can change your password by logging out and using the "Forgot Password" feature on the login screen.',
            ),
            _buildFAQItem(
              question: 'How do I edit my profile?',
              answer: 'Go to the Profile tab and tap on "Edit Profile" or the pen icon on the top right corner.',
            ),
            _buildFAQItem(
              question: 'How do I report a user or inappropriate content?',
              answer: 'We have a strict Zero Tolerance policy. You can report any user directly from their profile or post. Our moderation team will take immediate action against explicitly violent or inappropriate content.',
            ),
            _buildFAQItem(
              question: 'How do I delete my account?',
              answer: 'You can permanently delete your account and all associated data from the "Settings" > "Delete Account" menu. This action cannot be undone.',
            ),
            _buildFAQItem(
              question: 'Is my data secure?',
              answer: 'Yes, we take security very seriously and encrypt sensitive information to ensure your privacy.',
            ),
            SizedBox(height: 32.h),
            _buildContactSection(),
            SizedBox(height: 32.h),
            _buildQuickLinks(context),
            SizedBox(height: 24.h),
            Center(
              child: Text(
                'Version 1.0.0 (Build 12)',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFFFF4D8D),
        collapsedIconColor: Colors.white54,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1040), Color(0xFF0D1B4B)],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D8D).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.email_rounded, color: Color(0xFFFF4D8D)),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Support',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'support@showoff.com',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        _buildLinkItem(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          onTap: () => context.push('/profile/privacy-policy'),
        ),
        SizedBox(height: 12.h),
        _buildLinkItem(
          icon: Icons.description_rounded,
          title: 'Terms of Service',
          onTap: () => context.push('/profile/privacy-policy'), // Re-using privacy policy screen for now
        ),
      ],
    );
  }

  Widget _buildLinkItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF4D8D), size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
