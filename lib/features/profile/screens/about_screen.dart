import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/custom_assets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C1F),
        elevation: 0,
        title: Text(
          'About Show Off',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Image.asset(
              CustomAssets.transparentLogo,
              height: 120.h,
            ),
            SizedBox(height: 24.h),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Color(0xFFFF4D8D), Color(0xFF007BFF)],
              ).createShader(r),
              child: Text(
                'Show Off',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 40.h),
            _buildInfoCard(
              title: 'Our Mission',
              content: 'Show Off is designed to help you connect, share your passion, and discover like-minded people around the world in a fun, interactive way.',
            ),
            SizedBox(height: 20.h),
            _buildInfoCard(
              title: 'Developer',
              content: 'Built with ❤️ by Rana Sheikh. Dedicated to creating awesome mobile experiences.',
            ),
            SizedBox(height: 40.h),
            Text(
              '© 2026 Show Off Inc. All rights reserved.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
