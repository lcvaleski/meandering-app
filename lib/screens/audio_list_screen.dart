import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:sleepless_app/screens/play_screen.dart';
import '../models/audio_item.dart';
import '../services/audio_fetch.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../revenuecat_constants.dart';
import '../services/logger_service.dart';

class AudioListScreen extends StatefulWidget {
  final String? selectedGender;
  final String? selectedStory;

  const AudioListScreen(
      {super.key, required this.selectedStory, required this.selectedGender});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  late Future<Map<String, Map<String, List<AudioItem>>>> futureAudioList;
  bool _isSubscribed = false;

  Future<void> _checkSubscriptionStatus() async {
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      setState(() {
        _isSubscribed = customerInfo.entitlements.active[entitlementID]?.isActive ?? false;
      });
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  Future<void> _showPaywall() async {
    try {
      logger.i('Fetching RevenueCat offerings');
      final Offerings offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        logger.i('Presenting paywall for premium entitlement');
        await RevenueCatUI.presentPaywallIfNeeded('premium');
        logger.i('Paywall presented successfully');
        await _checkSubscriptionStatus();
      } else {
        logger.w('No offerings available');
      }
    } catch (e, stack) {
      logger.e('Error presenting paywall', error: e, stackTrace: stack);
    }
  }

  void subscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.yellow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return GestureDetector(
          key: const Key('subscriptionModal'),
          onTap: () {
            Navigator.of(context).pop();
            _showPaywall();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 125,
            alignment: Alignment.center,
            child: const Text(
              'Subscribe to access',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureAudioList = fetchAudioList();
    _checkSubscriptionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('audioListScreenAppBar'),
        title: Text(
          '${widget.selectedStory} library',
          style: TextStyle(
              color: Colors.white
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.yellow,
        ),
      ),
      body: FutureBuilder<Map<String, Map<String, List<AudioItem>>>>(
        future: futureAudioList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                strokeWidth: 8.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white)),
            );
          } else {
            final categorizedAudios = snapshot.data ?? {};

            if (!categorizedAudios.containsKey(widget.selectedStory)) {
              return _buildNoAudioMessage();
            }

            return _buildAudioList(categorizedAudios[widget.selectedStory]!);
          }
        },
      ),
    );
  }

  /// Displays a message when no audio is found.
  Widget _buildNoAudioMessage() {
    return Center(
      child: Text('No audio found for ${widget.selectedStory}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  /// Builds the list of audio categories and items.
  Widget _buildAudioList(Map<String, List<AudioItem>> categoryData) {
    if (!categoryData.containsKey(widget.selectedGender)) {
      return _buildNoAudioMessage();
    }

    final List<AudioItem> filteredAudios = categoryData[widget.selectedGender] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: filteredAudios.map((audioItem) => _buildAudioItem(audioItem)).toList(),
      ),
    );
  }

  /// Builds a single audio item tile.
  Widget _buildAudioItem(AudioItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 16.0),
      child: GestureDetector(
        key: Key('audioItem'),
        onTap: _isSubscribed
            ? () => _navigateToPlayScreen(item.id)
            : () => subscriptionModal(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.black12, width: 7),
            gradient: const LinearGradient(
              colors: [Color(0xFF5C6689), Color(0xFF3B3E56)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              item.subtopic,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.yellow,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// Navigates to the PlayScreen with the selected ID.
  void _navigateToPlayScreen(String? id) {
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayScreen(
          selectedGender: widget.selectedGender,
          selectedStory: widget.selectedStory,
          isArchived: true,
          id: id,
        ),
        settings: RouteSettings(name: 'audio_list_screen/play_screen/${widget.selectedStory}_${widget.selectedGender}'), // Firebase tracking
      ),
    );
  }
}
