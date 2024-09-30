import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';

class PlayerProfilePage extends StatefulWidget {
  final PlayerModel profile;

  PlayerProfilePage({required this.profile});

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to show the edit name dialog
  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Enter new name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: commonText("Cancel", color: Colors.black),
            ),
            GestureDetector(
              onTap: () async {
                // Update the local state
                setState(() {
                  widget.profile.name = _nameController.text;
                });

                // Update the name in Firebase Firestore
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  User? user = auth.currentUser;

                  if (user != null) {
                    // Reference to the player's document in Firestore
                    await FirebaseFirestore.instance
                        .collection('players')
                        .doc(user.uid) // Assuming user.uid is the document ID
                        .update({
                      'name': _nameController.text
                    }); // Update only the 'name' field

                    print('Name updated in Firestore successfully!');
                  }
                } catch (e) {
                  print('Failed to update name in Firestore: $e');
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: commonText("Save", color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: commonText(
            widget.profile.name != null
                ? "${widget.profile.name}'s Profile"
                : "Player Profile",
            color: Colors.black,
            isBold: true,
            size: 21),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),

          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Info Section
                buildProfileSection(
                  title: "Player Information",
                  content: [
                    buildEditableNameItem(),
                    buildProfileItem("Game ID", widget.profile.gameId),
                    buildProfileItem("Level", widget.profile.level.toString()),
                  ],
                ),
                SizedBox(height: 16.0),

                // Performance Metrics Section
                buildProfileSection(
                  title: "Performance Metrics",
                  content: [
                    buildProfileItem("Matches Played",
                        widget.profile.matchesPlayed.toString()),
                    buildProfileItem(
                        "Total Wins", widget.profile.matchTotalWin.toString()),
                    buildProfileItem("Total Losses",
                        widget.profile.matchTotalLose.toString()),
                    buildProfileItem("Hard Matches Played",
                        widget.profile.hardMatchesPlayed.toString()),
                    buildProfileItem(
                        "Base Liked", widget.profile.baseLiked.toString()),
                    buildProfileItem("Base Disliked",
                        widget.profile.baseDisliked.toString()),
                    buildProfileItem(
                        "Ball Damage", widget.profile.ballDamage.toString()),
                    buildProfileItem("Total Bricks Destroyed",
                        widget.profile.totalBricksDestroyed.toString()),
                  ],
                ),
                SizedBox(height: 16.0),

                // Brick Health Section
                buildProfileSection(
                  title: "Brick Health Metrics",
                  content: [
                    buildProfileItem("Standard Wall Health",
                        widget.profile.standardWallHealth.toString()),
                    buildProfileItem("Explosive Wall Health",
                        widget.profile.explosiveWallHealth.toString()),
                    buildProfileItem("Healing Wall Health",
                        widget.profile.healingWallHealth.toString()),
                    buildProfileItem("Invisible Wall Health",
                        widget.profile.invisibleWallHealth.toString()),
                    buildProfileItem("Speed Wall Health",
                        widget.profile.speedWallHealth.toString()),
                    buildProfileItem("Multi-Hit Wall Health",
                        widget.profile.multiHitWallHealth.toString()),
                    buildProfileItem("Power-Up Wall Health",
                        widget.profile.powerUpWallHealth.toString()),
                    buildProfileItem("Number of Unbreakable Walls",
                        "${widget.profile.numberOfUnbreakableWall.toString()}%"),
                    buildProfileItem("Max Brick Limit",
                        widget.profile.maxBrickLimit.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build profile section with a list of items
  Widget buildProfileSection(
      {required String title, required List<Widget> content}) {
    return Card(
      color: Colors.black54,
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(
              title,
              size: 21,
              color: primaryColor,
              isBold: true,
            ),
            Divider(thickness: 1.5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ],
        ),
      ),
    );
  }

  // Build individual profile items
  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          commonText(
            label,
            size: 16,
          ),
          commonText(value, size: 16),
        ],
      ),
    );
  }

  // Build editable name item
  Widget buildEditableNameItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          commonText("Name", size: 16),
          Row(
            children: [
              commonText(
                widget.profile.name ?? "Unknown",
                size: 16,
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit, color: primaryColor),
                onPressed: _showEditNameDialog, // Open dialog to edit name
              ),
            ],
          ),
        ],
      ),
    );
  }
}
