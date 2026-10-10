// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:confettie_plus/confettie_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/showoff_controller.dart';
import '../controllers/feed_audio_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/services/socket_service.dart';
import '../../chat/controllers/chat_controller.dart';
import '../widgets/showoff_empty_state.dart';
import '../widgets/showoff_fabs.dart';
import '../widgets/showoff_header.dart';
import '../widgets/showoff_post_card.dart';
import 'create_showoff_screen.dart';

class ShowOffFeedScreen extends StatefulWidget {
  const ShowOffFeedScreen({Key? key}) : super(key: key);

  @override
  State<ShowOffFeedScreen> createState() => _ShowOffFeedScreenState();
}

class _ShowOffFeedScreenState extends State<ShowOffFeedScreen> {
  final ShowOffController _showOffCtrl = Get.put(ShowOffController());
  final FeedAudioController _audioCtrl = Get.put(FeedAudioController());
  final AuthController _authCtrl = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _fabVisible = ValueNotifier(true);
  bool _showMyPosts = false;
  bool _paginationLocked = false; // throttle pagination
  String _searchQuery = '';
  bool _isPrivacyDialogShowing = false;
  late final ConfettieController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettieController(
      duration: const Duration(seconds: 2),
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrivacyPolicy();
    });
  }

  @override
  void dispose() {
    _audioCtrl.pauseMusic();
    _scrollController.dispose();
    _fabVisible.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _checkPrivacyPolicy() {
    final user = _authCtrl.currentUser.value;
    if (user != null &&
        !user.hasAcceptedPrivacyPolicy &&
        !_isPrivacyDialogShowing) {
      _isPrivacyDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent dismissing with back button
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E1E2C).withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Update on Privacy Policy & Terms',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'We have updated our Privacy Policy and Terms of Service to include strict content guidelines, zero tolerance for explicit/violent content, and limitation of liability. You must read and accept them to continue using the app.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await context.push('/profile/privacy-policy');
                      final updatedUser = _authCtrl.currentUser.value;
                      if (updatedUser != null &&
                          updatedUser.hasAcceptedPrivacyPolicy &&
                          mounted) {
                        Navigator.pop(context); // Close dialog
                      }
                    },
                    child: const Text(
                      'Read Policy',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _onScroll() {
    if (_paginationLocked) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      _paginationLocked = true;
      (_showMyPosts ? _showOffCtrl.fetchMyPosts() : _showOffCtrl.fetchFeed())
          .whenComplete(() => _paginationLocked = false);
    }
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (n is ScrollStartNotification || n is ScrollUpdateNotification) {
        if (_fabVisible.value) _fabVisible.value = false;
      } else if (n is ScrollEndNotification) {
        if (!_fabVisible.value) _fabVisible.value = true;
      }
    });
    return false;
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.fixed),
      );
  }

  Future<void> _chooseUser(String targetUserId) async {
    final newlyChosen = await _showOffCtrl.chooseUser(targetUserId);
    if (!mounted) return;
    if (newlyChosen == null) {
      return _toast('Could not send love. Please try again.');
    }
    if (!newlyChosen)
      return _toast('You have already shown love to this person ✅');

    _confettiController.play();

    SocketService.emitWithAck('access_chat', {'userId': targetUserId}, (res) {
      if (!mounted) return;
      final success = res is Map && res['success'] == true;
      if (success) {
        Get.find<ChatController>().sendMessage(
          res['chat']['_id'],
          'Sending love from Show Off! ❤️',
        );
      } else {
        _toast('Loved, but the message could not be sent.');
      }
    });
  }

  void _messageUser(String targetUserId, String targetUserName) {
    SocketService.emitWithAck('access_chat', {'userId': targetUserId}, (res) {
      if (!mounted) return;
      if (res is Map && res['success'] == true) {
        context.push('/chat/${res['chat']['_id']}', extra: targetUserName);
      } else {
        _toast(
          (res is Map ? res['message'] : null) ??
              'Could not open the chat. Please try again.',
        );
      }
    });
  }

  Future<void> _confirmDelete(String postId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This post will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) _showOffCtrl.deletePost(postId);
  }

  void _onToggle(bool value) {
    setState(() => _showMyPosts = value);
    if (value && _showOffCtrl.myPosts.isEmpty) {
      _showOffCtrl.fetchMyPosts(refresh: true);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _refresh() => _showMyPosts
      ? _showOffCtrl.fetchMyPosts(refresh: true)
      : _showOffCtrl.fetchFeed(refresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C1F),
      body: ConfettieWidget(
        controller: _confettiController,
        shapes: const [HeartShape()],
        colors: const [Colors.red, Colors.pinkAccent, Colors.pink],

        numberOfParticles: 80,
        minParticleSize: 10.0,
        maxParticleSize: 20.0,

        gravity: 250.0,
        blastForce: 450.0,
        drag: 0.06,

        blastDirection: BlastDirection.up,
        emissionSource: Alignment.center,
        emissionBehavior: EmissionBehavior.burst,

        child: SafeArea(
          child: Column(
            children: [
              ShowOffHeader(
                showMyPosts: _showMyPosts,
                onChanged: _onToggle,
                onSearch: _onSearchChanged,
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: Obx(_buildBody),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _fabVisible,
        builder: (_, visible, __) => Obx(
          () => ShowOffFabs(
            visible: visible,
            unreadCount: Get.find<ChatController>().unreadChatCount,
            onChats: () => context.push('/chat-list'),
            onAddPost: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateShowOffScreen()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    var posts = _showMyPosts ? _showOffCtrl.myPosts : _showOffCtrl.feedPosts;

    if (_searchQuery.isNotEmpty) {
      posts = posts
          .where((p) {
            final name = p.user?.name.toLowerCase() ?? '';
            final username = p.user?.username.toLowerCase() ?? '';
            final email = p.user?.email.toLowerCase() ?? '';
            return name.contains(_searchQuery) ||
                username.contains(_searchQuery) ||
                email.contains(_searchQuery);
          })
          .toList()
          .obs;
    }

    final loading = _showMyPosts
        ? _showOffCtrl.isLoadingMyPosts.value
        : _showOffCtrl.isLoadingFeed.value;
    final bool hasSearchOrFilter =
        _showOffCtrl.currentFilters.isNotEmpty || _searchQuery.isNotEmpty;

    if (posts.isEmpty) {
      return loading
          ? const Center(child: CircularProgressIndicator())
          : ShowOffEmptyState(
              isMyPosts: _showMyPosts,
              isFiltering: hasSearchOrFilter,
            );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 150),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: posts.length + (loading ? 1 : 0),
        addRepaintBoundaries: false, // we add manually per card
        itemBuilder: (_, i) {
          if (i == posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = posts[i];
          return RepaintBoundary(
            key: ValueKey(post.id),
            child: VisibilityDetector(
              key: Key('visibility-${post.id}'),
              onVisibilityChanged: (info) {
                if (info.visibleFraction > 0.5) {
                  if (post.musicUrl != null && post.musicUrl!.isNotEmpty) {
                    Get.find<FeedAudioController>().playMusic(post.musicUrl!);
                  } else {
                    Get.find<FeedAudioController>().pauseMusic();
                  }
                }
              },
              child: ShowOffPostCard(
                post: post,
                isMine: post.user?.id == _authCtrl.currentUser.value?.id,
                onChoose: () => _chooseUser(post.user!.id),
                onMessage: () => _messageUser(post.user!.id, post.user!.name),
                onDelete: () => _confirmDelete(post.id),
                onReport: () async {
                  final error = await _showOffCtrl.reportPost(post.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? 'Post reported successfully!'),
                        backgroundColor: error != null
                            ? Colors.redAccent
                            : Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
