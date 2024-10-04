// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/profile.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';

class Leaderboard extends StatefulWidget {
  PlayerModel? playerModel;
  Leaderboard({super.key, this.playerModel});
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late Future<List<PlayerModel>> _leaderboardDataFuture;

  // Categories for leaderboard
  final List<String> categories = [
    'Matches Played',
    'Matches Won',
    'Matches Lost',
    'Base Liked',
    'Base Disliked',
    'Bricks Destroyed',
  ];

  String selectedCategory = 'Matches Played'; // Default selected category

  @override
  void initState() {
    super.initState();
    _leaderboardDataFuture = _fetchLeaderboardData();
  }

  Future<List<PlayerModel>> _fetchLeaderboardData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('players')
        .get(); // Assuming you have a 'Players' collection

    return querySnapshot.docs
        .map((doc) => PlayerModel.fromMap(doc.data()))
        .toList();
  }

  List<PlayerModel> _filterAndSortPlayers(
      List<PlayerModel> playersList, String category) {
    // Filter and sort players based on the selected category
    List<PlayerModel> filteredPlayers;

    switch (category) {
      case 'Matches Played':
        filteredPlayers = playersList;
        filteredPlayers.sort((a, b) => (b.matchTotalWin + b.matchTotalLose)
            .compareTo(a.matchTotalWin + a.matchTotalLose));
        break;
      case 'Matches Won':
        filteredPlayers = playersList;
        filteredPlayers.sort((a, b) =>
            b.matchTotalWin.compareTo(a.matchTotalWin)); // Sort by wins
        break;
      case 'Matches Lost':
        filteredPlayers = playersList;
        filteredPlayers.sort((a, b) =>
            b.matchTotalLose.compareTo(a.matchTotalLose)); // Sort by losses
        break;
      case 'Base Liked':
        filteredPlayers = playersList;
        filteredPlayers.sort(
            (a, b) => b.baseLiked.compareTo(a.baseLiked)); // Sort by likes
        break;
      case 'Base Disliked':
        filteredPlayers = playersList;
        filteredPlayers.sort((a, b) =>
            b.baseDisliked.compareTo(a.baseDisliked)); // Sort by dislikes
        break;
      case 'Bricks Destroyed':
        filteredPlayers = playersList;
        filteredPlayers.sort((a, b) => b.totalBricksDestroyed
            .compareTo(a.totalBricksDestroyed)); // Sort by bricks destroyed
        break;
      default:
        filteredPlayers = playersList;
    }

    return filteredPlayers;
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
            color: Colors.black26,
            colorBlendMode: BlendMode.colorBurn,
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Center(
                      child: commonText("LeaderShip       ",
                          isBold: true, size: 20),
                    ))
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                // Scrollable and Tappable Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory =
                                category; // Update selected category
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: commonText(
                              category,
                              size: 11,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: FutureBuilder<List<PlayerModel>>(
                    future: _leaderboardDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: commonText('No player data found'));
                      }

                      var playersList = snapshot.data!;
                      var filteredPlayers =
                          _filterAndSortPlayers(playersList, selectedCategory);
                      return ListView.builder(
                        itemCount: filteredPlayers.length,
                        itemBuilder: (context, index) {
                          var player = filteredPlayers[index];
                          return ListTile(
                            title: commonText('Player: ${player.name}',
                                isBold: true),
                            subtitle: commonText(
                                'Matches Played: ${player.matchTotalWin + player.matchTotalLose}, Wins: ${player.matchTotalWin}, Losses: ${player.matchTotalLose},\nBricks Destroyed: ${player.totalBricksDestroyed}, Base Liked: ${player.baseLiked}',
                                isBold: true),
                            trailing: const Icon(Icons.leaderboard,
                                color: primaryColor),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerProfilePage(
                                      profile: player,
                                    ),
                                  ));
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
