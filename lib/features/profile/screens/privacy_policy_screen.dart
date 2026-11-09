import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final AuthController _authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C1F),
        elevation: 0,
        title: Text(
          'Privacy Policy',
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
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us, such as when you create or modify your account, request on-demand services, contact customer support, or otherwise communicate with us.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We may use the information we collect about you to provide, maintain, and improve our services, including, for example, to facilitate payments, send receipts, provide products and services you request, develop new features, provide customer support, and send product updates.',
            ),
            _buildSection(
              title: '3. Sharing of Information',
              content:
                  'We may share the information we collect about you as described in this Statement or as described at the time of collection or sharing, including as follows: with third party service providers; in response to a request for information by a competent authority if we believe disclosure is in accordance with, or is otherwise required by, any applicable law, regulation, or legal process.',
            ),
            _buildSection(
              title: '4. Security',
              content:
                  'We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.',
            ),
            _buildSection(
              title: '5. Content Policy & Zero Tolerance',
              content:
                  'We strictly prohibit the posting, sharing, or distribution of any adult content (18+), sexually explicit materials, extreme violence, blood, gore, or highly disturbing imagery on our platform. We maintain a zero-tolerance policy against such activities. If any user is found violating these guidelines, immediate and strict action will be taken. This includes the permanent deletion of the offending posts without prior notice and the immediate suspension or permanent ban of the user\'s account. By using our services, you agree to adhere to these strict content guidelines to maintain a safe environment for everyone.',
            ),
            _buildSection(
              title: '6. Limitation of Liability & Fraud Prevention',
              content:
                  'Show Off serves solely as a platform for communication. We do not take any responsibility for the actions, messages, or intentions of our users. If a user falls victim to scams, fraud, deception, or any form of monetary or emotional exploitation through private messages, the platform and its owners hold no liability. Users are strongly advised not to share sensitive personal information, bank details, or passwords with anyone. Any transactions or agreements made between users are strictly at their own risk.',
            ),
            _buildSection(
              title: '7. Disclaimer & User Independence',
              content:
                  'By using Show Off, you acknowledge that the platform operates neutrally and does not actively monitor or endorse the private communications of its users. The developers, owners, and management of Show Off are entirely free from any legal, financial, or moral obligations arising from user interactions. You assume full responsibility for your behavior, posts, and communications on the platform.',
            ),
            _buildSection(
              title: '8. Age Restrictions (COPPA Compliance)',
              content:
                  'Our services are not directed to individuals under the age of 18. We do not knowingly collect personal information from children. If we become aware that a child under 18 has provided us with personal information, we will take immediate steps to delete such information and terminate the account.',
            ),
            _buildSection(
              title: '9. User Data Rights (GDPR & CCPA)',
              content:
                  'Depending on your location, you may have certain rights regarding your personal data, including the right to access, correct, or delete your data (Right to be Forgotten). You can exercise these rights by deleting your account through the app settings. We do not sell your personal data to third parties.',
            ),
            _buildSection(
              title: '10. Intellectual Property',
              content:
                  'All content, design, logos, and features of Show Off are the exclusive property of the developers. Users may not copy, modify, distribute, or reverse-engineer any part of the app. However, users retain full ownership of the original content and media they share on the platform.',
            ),
            _buildSection(
              title: '11. Governing Law & Dispute Resolution',
              content:
                  'These terms and policies are governed by the local laws of the developers\' jurisdiction. Any disputes, claims, or legal proceedings arising from or related to the use of Show Off shall be resolved exclusively in the courts of the developers\' jurisdiction. Class action lawsuits are strictly prohibited.',
            ),
            _buildSection(
              title: '12. Modifications to Terms',
              content:
                  'We reserve the right to modify or update these Privacy Policies and Terms of Service at any time without prior notice. It is the user\'s responsibility to review these terms periodically. Continued use of the platform after changes implies acceptance of the new terms.',
            ),
            _buildSection(
              title: '13. Account Suspension & Reporting Policy',
              content:
                  'To ensure the safety and well-being of our community, we strictly monitor user reports. If your account receives reports from 5 different users for inappropriate behavior, harassment, scamming, or policy violations, your account will be immediately and permanently suspended. Once suspended, you will lose all access to the app and will not be able to create a new account.',
            ),
            SizedBox(height: 40.h),
            Center(
              child: Text(
                'Last updated: October 2026',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Obx(() {
              final user = _authCtrl.currentUser.value;
              final bool showAcceptButton = user != null && !user.hasAcceptedPrivacyPolicy;
              if (!showAcceptButton) return const SizedBox.shrink();
              
              return Column(
                children: [
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await _authCtrl.acceptPrivacyPolicy();
                        if (success && mounted) {
                          Navigator.pop(context);
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to accept policy. Please try again.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D8D),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Accept & Continue',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF4D8D),
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
