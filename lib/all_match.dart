// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';
import 'package:shatterforge/src/widgets/game_app.dart';

class AllMatch extends StatefulWidget {
  PlayerModel? playerModel;
  AllMatch({super.key, this.playerModel});
  _AllMatchState createState() => _AllMatchState();
}

class _AllMatchState extends State<AllMatch>
    with SingleTickerProviderStateMixin {
  late Future<List<GridData>> _playableMapsFuture;
  late TabController _tabController;

  // Categories for tabs
  final List<String> categories = [
    'All',
    'Liked',
    'Disliked',
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  void initState() {
    super.initState();
    _playableMapsFuture = _fetchPlayableMaps();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  Future<List<GridData>> _fetchPlayableMaps() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Maps')
        .where('isPlayable', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => GridData.fromMap(doc.data()))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  List<GridData> _filterAndSortMaps(List<GridData> mapsList, String category) {
    // Filter and sort maps based on the selected category
    List<GridData> filteredMaps;

    switch (category) {
      case 'Liked':
        filteredMaps = mapsList.where((map) => map.like >= 0).toList();
        filteredMaps.sort(
            (a, b) => b.like.compareTo(a.like)); // Sort by likes descending
        break;
      case 'Disliked':
        filteredMaps = mapsList.where((map) => map.dislike >= 0).toList();
        filteredMaps.sort((a, b) =>
            b.dislike.compareTo(a.dislike)); // Sort by dislikes descending
        break;
      case 'Easy':
        filteredMaps = mapsList.where((map) => map.easy >= 0).toList();
        filteredMaps.sort(
            (a, b) => b.easy.compareTo(a.easy)); // Sort by easy descending
        break;
      case 'Medium':
        filteredMaps = mapsList.where((map) => map.medium >= 0).toList();
        filteredMaps.sort((a, b) =>
            b.medium.compareTo(a.medium)); // Sort by medium descending
        break;
      case 'Hard':
        filteredMaps = mapsList.where((map) => map.hard >= 0).toList();
        filteredMaps.sort(
            (a, b) => b.hard.compareTo(a.hard)); // Sort by hard descending
        break;
      case 'All':
      default:
        filteredMaps = mapsList; // Show all for the bricks category
        break;
    }

    return filteredMaps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.white,
                indicatorColor: primaryColor,
                dividerColor: Colors.white,
                tabs: categories
                    .map((category) => Tab(
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: commonText(category, size: 11)),
                        ))
                    .toList(),
              ),
              Expanded(
                child: FutureBuilder<List<GridData>>(
                  future: _playableMapsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: commonText('No playable maps found'));
                    }

                    var mapsList = snapshot.data!;
                    return TabBarView(
                      controller: _tabController,
                      children: categories.map((category) {
                        // Filter and sort maps based on the selected category
                        var filteredMaps =
                            _filterAndSortMaps(mapsList, category);
                        return ListView.builder(
                          itemCount: filteredMaps.length,
                          itemBuilder: (context, index) {
                            var gridData = filteredMaps[index];
                            return ListTile(
                              title: commonText(
                                  'Base: ${gridData.row}x${gridData.column}'),
                              subtitle: commonText(
                                  'Liked: ${gridData.like}, Disliked: ${gridData.dislike}, Easy: ${gridData.easy}, Medium: ${gridData.medium}, Hard: ${gridData.hard}'),
                              trailing: const Icon(Icons.play_arrow,
                                  color: Colors.green),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    Config.initialize(context);
                                    return GameApp(
                                      gridData: gridData,
                                      playerModel: widget.playerModel,
                                    );
                                  },
                                ));
                              },
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
