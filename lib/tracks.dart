import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player_app/music_player.dart';
import 'dart:math';

class Tracks extends StatefulWidget {
  @override
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songsList = [];
  DeviceModel deviceModel;
  int currentIndex=0;
  bool searching = false;
  List<int> filteredIndex = [];

  final TextEditingController searchText = TextEditingController();

  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();

  getDevice() async => deviceModel = await OnAudioQuery().queryDeviceInfo();

  void getTracks() async {
    songsList = await audioQuery.querySongs();
    setState(() {
      songsList = songsList;
      filteredIndex = [for(var i=0; i<songsList.length; i+=1) i];
    });
  }

  void initState() {
    super.initState();
    getDevice();
    getTracks();
  }

  void changeTrack(bool isNext, int cIndex, bool shuffle) {
    if (shuffle) {
      shuffleSongs();
    } else {
      if (isNext) {
        if (cIndex != songsList.length - 1) {
          currentIndex = cIndex + 1;
        } else {
          currentIndex = 0;
        }
      } else {
        if (cIndex != 0) {
          currentIndex = cIndex - 1;
        } else {
          currentIndex = songsList.length - 1;
        }
      }
      key.currentState.setSong(songsList[currentIndex], currentIndex);
    }
  }

  void shuffleSongs() {
    Random random = new Random();
    int randomNumber = random.nextInt(songsList.length);
    currentIndex = randomNumber;
    key.currentState.setSong(songsList[randomNumber], currentIndex);
  }

  void repeatSong(int cIndex) {
    key.currentState.setSong(songsList[cIndex], cIndex);
  }

  void resetFilteredIndex() {
    setState(() {
      filteredIndex.clear();
      filteredIndex = [for(var i=0; i<songsList.length; i+=1) i];
    });
  }

  void searchSong(String query) {
    for (var i=0; i<songsList.length; i++) {
      if (songsList[i].title.toLowerCase().contains(query))  {
        setState(() => filteredIndex.add(i));
      } else if (songsList[i].artist.toLowerCase().contains(query) ) {
        setState(() => filteredIndex.add(i));
      }
    }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255,3,66),
        title: searching ?
          TextField(
            controller: searchText,
            onChanged: (text) {
              setState(() {
                filteredIndex.clear();
                searchSong(text.toLowerCase());
              });
            },
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: "Search Song",
              hintStyle: TextStyle(
                color: Colors.white,
              )
            ),
          )
          :Text(
            "Music Player",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searching = !searching;
                if (!searching) {
                  resetFilteredIndex();
                } else {
                  searchText.clear();
                }
              });
            },
            icon: searching ?
              Icon(
                Icons.clear,
                color: Colors.white
              )
              :Icon(
                Icons.search,
                color: Colors.white
              )
          )
        ],
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: filteredIndex.length,
          itemBuilder: (context, index) => ListTile(
            leading: QueryArtworkWidget(
              keepOldArtwork: true,
              id: songsList[filteredIndex[index]].id,
              type: ArtworkType.AUDIO,
              artwork: songsList[filteredIndex[index]].artwork,
              deviceSDK: deviceModel.sdk,
              artworkBorder: BorderRadius.circular(5),
            ),
            title: Text(songsList[filteredIndex[index]].title),
            subtitle: Text(songsList[filteredIndex[index]].artist),
            onTap: () {
              currentIndex = filteredIndex[index];
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MusicPlayer(
                    songModel: songsList[filteredIndex[index]],
                    currentIndex: currentIndex,
                    deviceModel: deviceModel,
                    key: key,
                    changeTrack: changeTrack,
                    shuffleSongs: shuffleSongs,
                    repeatSong: repeatSong
                  )
                )
              );
            },
          ),
        ),
      ),
    );
  }
}
