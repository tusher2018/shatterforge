import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerUpgradePage extends StatefulWidget {
  final PlayerModel playerModel;

  PlayerUpgradePage({required this.playerModel});

  @override
  _PlayerUpgradePageState createState() => _PlayerUpgradePageState();
}

class _PlayerUpgradePageState extends State<PlayerUpgradePage> {
  // Map to track remaining time for each item
  Map<String, Duration> remainingTime = {
    'Standard Wall': Duration.zero,
    'Explosive Wall': Duration.zero,
    'Speed Up Wall': Duration.zero,
    'Invisible Wall': Duration.zero,
    'Multi-Hit Wall': Duration.zero,
    'Power-Up Wall': Duration.zero,
    'Unbreakable Wall': Duration.zero,
    'Ball Damage': Duration.zero,
  };

  Map<String, bool> isUpgrading = {
    'Standard Wall': false,
    'Explosive Wall': false,
    'Speed Up Wall': false,
    'Invisible Wall': false,
    'Multi-Hit Wall': false,
    'Power-Up Wall': false,
    'Unbreakable Wall': false,
    'Ball Damage': false,
  };

  Map<String, int> upgradeCounts = {
    'Standard Wall': 0,
    'Explosive Wall': 0,
    'Speed Up Wall': 0,
    'Invisible Wall': 0,
    'Multi-Hit Wall': 0,
    'Power-Up Wall': 0,
    'Unbreakable Wall': 0,
    'Ball Damage': 0,
  };

  Map<String, int> upgradeCost = {
    'Standard Wall': 20,
    'Explosive Wall': 150,
    'Speed Up Wall': 120,
    'Invisible Wall': 200,
    'Multi-Hit Wall': 140,
    'Power-Up Wall': 200,
    'Unbreakable Wall': 500,
    'Ball Damage': 50,
  };

  Map<String, Duration> upgradeTimes = {
    'Standard Wall': const Duration(seconds: 3),
    'Explosive Wall': const Duration(seconds: 3),
    'Speed Up Wall': const Duration(seconds: 3),
    'Invisible Wall': const Duration(seconds: 3),
    'Multi-Hit Wall': const Duration(seconds: 3),
    'Power-Up Wall': const Duration(seconds: 3),
    'Unbreakable Wall': const Duration(seconds: 3),
    'Ball Damage': const Duration(seconds: 3),
  };

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data here
    if (_allItemsUpgradedThisLevel()) {
      _levelUp();
    }
  }

  bool _allItemsUpgradedThisLevel() {
    return widget.playerModel.hasUpgradedThisLevel.values
        .every((upgraded) => upgraded == true);
  }

  void _levelUp() {
    if (widget.playerModel.level < maxLevel) {
      setState(() {
        widget.playerModel.level++; // Increase the player's level
        widget.playerModel.hasUpgradedThisLevel
            .updateAll((key, value) => false); // Reset upgrade availability
      });
      // Update level in Firestore
      _updatePlayerData({'level': widget.playerModel.level});
    }
  }

  Future<void> _updatePlayerData(Map<String, dynamic> data) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('players')
            .doc(user.uid)
            .update(data);
        print('Player data updated in Firestore.');
      }
    } catch (e) {
      print('Error updating player data: $e');
    }
  }

  Future<void> _upgradeItem(String itemName, int minLevel) async {
    if (widget.playerModel.level < minLevel) {
      return;
    }

    if (widget.playerModel.hasUpgradedThisLevel[itemName] == true) {
      return;
    }

    if (widget.playerModel.coins < upgradeCost[itemName]!) {
      showCommonSnackbar(
        context,
        message: 'Insufficient gold',
        icon: Icons.error,
      );
      return;
    }
    widget.playerModel.coins -= upgradeCost[itemName]!;

    final upgradeDuration = upgradeTimes[itemName]!;

    setState(() {
      remainingTime[itemName] = upgradeDuration;
      isUpgrading[itemName] = true;
    });

    // Update the remaining time dynamically for this specific item
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime[itemName]!.inSeconds > 0) {
        setState(() {
          remainingTime[itemName] =
              remainingTime[itemName]! - Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });

    // Simulate upgrade time
    await Future.delayed(upgradeDuration);

    setState(() {
      // Upgrade item health/number within min and max constraints
      switch (itemName) {
        case 'Standard Wall':
          widget.playerModel.standardWallHealth =
              (widget.playerModel.standardWallHealth + 49);
          _updatePlayerData(
              {'standardWallHealth': widget.playerModel.standardWallHealth});
          break;
        case 'Explosive Wall':
          widget.playerModel.explosiveWallHealth =
              (widget.playerModel.explosiveWallHealth + 49);
          _updatePlayerData(
              {'explosiveWallHealth': widget.playerModel.explosiveWallHealth});
          break;
        case 'Speed Up Wall':
          widget.playerModel.speedWallHealth =
              (widget.playerModel.speedWallHealth + 49);
          _updatePlayerData(
              {'speedWallHealth': widget.playerModel.speedWallHealth});
          break;
        case 'Invisible Wall':
          widget.playerModel.invisibleWallHealth =
              (widget.playerModel.invisibleWallHealth + 49);
          _updatePlayerData(
              {'invisibleWallHealth': widget.playerModel.invisibleWallHealth});
          break;
        case 'Multi-Hit Wall':
          widget.playerModel.multiHitWallHealth =
              (widget.playerModel.multiHitWallHealth + 49);
          _updatePlayerData(
              {'multiHitWallHealth': widget.playerModel.multiHitWallHealth});
          break;
        case 'Power-Up Wall':
          widget.playerModel.powerUpWallHealth =
              (widget.playerModel.powerUpWallHealth + 49);
          _updatePlayerData(
              {'powerUpWallHealth': widget.playerModel.powerUpWallHealth});
          break;
        case 'Unbreakable Wall':
          widget.playerModel.numberOfUnbreakableWall =
              (widget.playerModel.numberOfUnbreakableWall + 1).clamp(25, 35);
          _updatePlayerData({
            'numberOfUnbreakableWall':
                widget.playerModel.numberOfUnbreakableWall
          });
          break;
        case 'Ball Damage':
          widget.playerModel.ballDamage = (widget.playerModel.ballDamage + 50);
          _updatePlayerData({'ballDamage': widget.playerModel.ballDamage});
          break;
      }

      isUpgrading[itemName] = false;
      widget.playerModel.hasUpgradedThisLevel[itemName] = true;

      upgradeCounts[itemName] = upgradeCounts[itemName]! + 1;

      _updatePlayerData({
        'hasUpgradedThisLevel': widget.playerModel.hasUpgradedThisLevel,
        'coin': widget.playerModel.coins
      });
    });

    // Optionally, level up if all items are upgraded
    if (_allItemsUpgradedThisLevel()) {
      _levelUp();
    }
  }

  Widget _buildUpgradeCard({
    required String itemName,
    required String imagePath,
    required int currentValue,
    required int cost,
    required Duration upgradeTime,
    required VoidCallback onUpgrade,
    bool isBall = false,
    bool isUnbreakable = false,
  }) {
    int levelDisplay = widget.playerModel.hasUpgradedThisLevel[itemName]!
        ? widget.playerModel.level + 1
        : widget.playerModel.level;
    return Card(
      elevation: 20,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: primaryColor),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            opacity: 0.5,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.colorBurn,
            ),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          imagePath,
                          width: 80,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    commonText(
                      "Level: $levelDisplay",
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          commonText(
                            itemName,
                            size: 14,
                            isBold: true,
                            color: Colors.white,
                          ),
                          commonText(
                              isBall
                                  ? "Damage: $currentValue"
                                  : isUnbreakable
                                      ? 'Walls: $currentValue%'
                                      : 'Health: $currentValue',
                              size: 14,
                              color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentValue / 200,
                        backgroundColor: primaryColor,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: commonText('Cost: $cost Gold',
                                      size: 12, color: Colors.yellow),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ElevatedButton(
                                  onPressed: widget.playerModel
                                          .hasUpgradedThisLevel[itemName]!
                                      ? null
                                      : onUpgrade,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: commonText(
                                    widget.playerModel
                                            .hasUpgradedThisLevel[itemName]!
                                        ? "Already Upgraded"
                                        : isUpgrading[itemName]!
                                            ? "Upgrading... (${remainingTime[itemName]!.inSeconds}s left)"
                                            : "Upgrade (${upgradeTimes[itemName]!.inSeconds}s)",
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shorten references to widget.playerModel for readability
    final player = widget.playerModel;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title:
            commonText('Upgrade', color: Colors.black, size: 20, isBold: true),
        actions: [
          commonText("Gold : ${widget.playerModel.coins}", color: Colors.black),
          SizedBox(
            width: 16,
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUpgradeCard(
                  itemName: 'Standard Wall',
                  imagePath: 'assets/images/standard_wall.png',
                  currentValue: player.standardWallHealth,
                  cost: upgradeCost['Standard Wall']!,
                  upgradeTime: upgradeTimes['Standard Wall']!,
                  onUpgrade: () => _upgradeItem('Standard Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Explosive Wall',
                  imagePath: 'assets/images/explosive_wall.png',
                  currentValue: player.explosiveWallHealth,
                  cost: upgradeCost['Explosive Wall']!,
                  upgradeTime: upgradeTimes['Explosive Wall']!,
                  onUpgrade: () => _upgradeItem('Explosive Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Speed Up Wall',
                  imagePath: 'assets/images/standard_wall.png',
                  currentValue: player.speedWallHealth,
                  cost: upgradeCost['Speed Up Wall']!,
                  upgradeTime: upgradeTimes['Speed Up Wall']!,
                  onUpgrade: () => _upgradeItem('Speed Up Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Invisible Wall',
                  imagePath: 'assets/images/Invisible_wall.png',
                  currentValue: player.invisibleWallHealth,
                  cost: upgradeCost['Invisible Wall']!,
                  upgradeTime: upgradeTimes['Invisible Wall']!,
                  onUpgrade: () => _upgradeItem('Invisible Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Multi-Hit Wall',
                  imagePath: 'assets/images/multi_hit_wall.png',
                  currentValue: player.multiHitWallHealth,
                  cost: upgradeCost['Multi-Hit Wall']!,
                  upgradeTime: upgradeTimes['Multi-Hit Wall']!,
                  onUpgrade: () => _upgradeItem('Multi-Hit Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Power-Up Wall',
                  imagePath: 'assets/images/powerup_wall.png',
                  currentValue: player.powerUpWallHealth,
                  cost: upgradeCost['Power-Up Wall']!,
                  upgradeTime: upgradeTimes['Power-Up Wall']!,
                  onUpgrade: () => _upgradeItem('Power-Up Wall', player.level),
                ),
                _buildUpgradeCard(
                  itemName: 'Unbreakable Wall',
                  imagePath: 'assets/images/unbreakable_wall.png',
                  currentValue: player.numberOfUnbreakableWall,
                  cost: upgradeCost['Unbreakable Wall']!,
                  upgradeTime: upgradeTimes['Unbreakable Wall']!,
                  onUpgrade: () =>
                      _upgradeItem('Unbreakable Wall', player.level),
                  isUnbreakable: true,
                ),
                _buildUpgradeCard(
                  itemName: 'Ball Damage',
                  imagePath: 'assets/images/ball.png',
                  currentValue: player.ballDamage,
                  cost: upgradeCost['Ball Damage']!,
                  upgradeTime: upgradeTimes['Ball Damage']!,
                  onUpgrade: () => _upgradeItem('Ball Damage', player.level),
                  isBall: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
