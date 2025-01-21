import 'package:flutter/material.dart';
import 'package:sleepless_app/screens/play_screen.dart';
import '../models/audio_item.dart';
import '../services/audio_fetch.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../revenuecat_constants.dart';

class AudioListScreen extends StatefulWidget {
  final String? selectedGender;
  final String? selectedStory;

  const AudioListScreen(
      {super.key, required this.selectedStory, required this.selectedGender});

  @override
  _AudioListScreenState createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  late Future<Map<String, Map<String, List<AudioItem>>>> futureAudioList;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    futureAudioList = fetchAudioList();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      setState(() {
        _isSubscribed = customerInfo.entitlements.active[entitlementID]?.isActive ?? false;
      });
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  void subscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _showPaywall();
          },
          child: Container(
            height: 75,
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



  Future<void> _showPaywall() async {
    try {
      Offerings? offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        await RevenueCatUI.presentPaywallIfNeeded('premium');
        // Check subscription status again after paywall is closed
        await _checkSubscriptionStatus();
      } else {
        debugPrint('No offerings available');
      }
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
    }
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
      child: Text("No audio found for ${widget.selectedStory}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  /// Builds the list of audio categories and items.
  Widget _buildAudioList(Map<String, List<AudioItem>> categoryData) {
    if (!categoryData.containsKey(widget.selectedGender)) {
      return _buildNoAudioMessage();
    }

    List<AudioItem> filteredAudios = categoryData[widget.selectedGender] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: filteredAudios.map((audioItem) => _buildAudioItem(audioItem)).toList(),
      ),
    );
  }


  /// Builds a category section with a title and list of audio items.
  Widget _buildCategory(MapEntry<String, List<AudioItem>> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAudioItems(entry.value),
      ],
    );
  }

  /// Builds a list of audio items.
  Widget _buildAudioItems(List<AudioItem> audioItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audioItems.length,
      itemBuilder: (context, index) => _buildAudioItem(audioItems[index]),
    );
  }

  /// Builds a single audio item tile.
  Widget _buildAudioItem(AudioItem item) {
    return ListTile(
      title: Text(
        item.subtopic,
        style: TextStyle(color: Colors.white),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow, color: Colors.yellow),
        onPressed: _isSubscribed
          ? () => _navigateToPlayScreen(item.id)
          : () => subscriptionModal(context),
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
      ),
    );
  }
}
