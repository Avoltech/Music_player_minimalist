import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongModel songModel;
  int currentIndex;
  DeviceModel deviceModel;
  Function changeTrack;
  Function shuffleSongs;
  Function repeatSong;

  final GlobalKey<MusicPlayerState> key;

  MusicPlayer(
      {this.songModel,
      this.currentIndex,
      this.deviceModel,
      this.changeTrack,
      this.shuffleSongs,
      this.repeatSong,
      this.key})
      : super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minValSlider = 0.0, maxValSlider = 0.0, curValSlider = 0.0;
  String currentTime = '', endTime = '';
  bool isPlaying = false;
  bool shuffle = false;
  bool repeat = false;

  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songModel, widget.currentIndex);
    player.positionStream.listen((duration) {
      curValSlider = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(curValSlider);
        if (curValSlider != 0.0) {
          if (curValSlider >= maxValSlider) {
            curValSlider = 0;
            if (repeat) {
              widget.repeatSong(widget.currentIndex);
            } else {
              if (shuffle) {
                widget.shuffleSongs();
              } else {
                widget.changeTrack(true, widget.currentIndex, shuffle);
              }
            }
          }
        }
      });
    });
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void setSong(SongModel songModel, int currentIndex) async {
    widget.songModel = songModel;
    await player.setUrl(widget.songModel.uri);
    curValSlider = minValSlider;
    maxValSlider = player.duration.inMilliseconds.toDouble();
    setState(() {
      widget.currentIndex = currentIndex;
      currentTime = getDuration(curValSlider);
      endTime = getDuration(maxValSlider);
    });
    isPlaying = false;
    changePlayStatus();
  }

  void changePlayStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double val) {
    Duration duration = Duration(milliseconds: val.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: EdgeInsets.fromLTRB(15, 140, 15, 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: QueryArtworkWidget(
              keepOldArtwork: true,
              size: 300,
              artworkHeight: 300,
              artworkWidth: 300,
              artworkQuality: FilterQuality.high,
              id: widget.songModel.id,
              type: ArtworkType.AUDIO,
              artwork: widget.songModel.artwork,
              deviceSDK: widget.deviceModel.sdk,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
            child: Text(
              widget.songModel.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
            child: Text(
              widget.songModel.artist,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: Color.fromARGB(255, 255, 3, 66),
              inactiveTrackColor: Colors.black12,
              activeTrackColor: Colors.black,
            ),
            child: Slider(
              min: minValSlider,
              max: maxValSlider,
              value: curValSlider,
              onChanged: (value) {
                curValSlider = value;
                player.seek(Duration(milliseconds: curValSlider.round()));
              },
            ),
          ),
          Container(
              transform: Matrix4.translationValues(0, -15, 0),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    endTime,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
          Container(
              margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      child: Icon(Icons.skip_previous,
                          color: Colors.grey, size: 55),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTrack(false, widget.currentIndex, shuffle);
                      }),
                  GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 4,
                              blurRadius: 4,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Color.fromARGB(255, 255, 3, 66),
                            size: 80),
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        changePlayStatus();
                      }),
                  GestureDetector(
                      child:
                          Icon(Icons.skip_next, color: Colors.grey, size: 55),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTrack(true, widget.currentIndex, shuffle);
                      })
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(50, 50, 50, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      child: Icon(Icons.shuffle_sharp,
                          color: shuffle
                              ? Color.fromARGB(255, 255, 3, 66)
                              : Colors.grey,
                          size: 35),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          shuffle = !shuffle;
                        });
                      }),
                  GestureDetector(
                      child: Icon(Icons.repeat,
                          color: repeat
                              ? Color.fromARGB(255, 255, 3, 66)
                              : Colors.grey,
                          size: 35),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          repeat = !repeat;
                        });
                      })
                ],
              ))
        ],
      ),
    ));
  }
}
