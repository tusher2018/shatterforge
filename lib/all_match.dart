import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';
import 'package:shatterforge/src/widgets/game_app.dart';

class AllMatch extends StatefulWidget {
  @override
  _AllMatchState createState() => _AllMatchState();
}

class _AllMatchState extends State<AllMatch> {
  late Future<List<GridData>> _playableMapsFuture;

  @override
  void initState() {
    super.initState();
    _playableMapsFuture = _fetchPlayableMaps();
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
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
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
                    child: const Icon(Icons.arrow_back_ios)),
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
                      return ListView.builder(
                        itemCount: mapsList.length,
                        itemBuilder: (context, index) {
                          var gridData = mapsList[index];
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
                                  return GameApp(gridData: gridData);
                                  //  GameWidget(
                                  //     game: BrickBreaker(gridData: gridData));
                                },
                              ));
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
