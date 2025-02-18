import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:overvoice_project/model/constant_value.dart';
import 'dart:developer';
import 'package:overvoice_project/model/listen_detail.dart';
import 'package:google_fonts/google_fonts.dart';

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  
  return [
    if (duration.inHours > 0) hours,
    minutes,
    seconds,
  ].join(':');
}

class ListenPage extends StatefulWidget {
  Map<String, dynamic> detailList;
  ListenDetails listenList;

  ListenPage(this.detailList, this.listenList, {super.key});

  @override
  State<ListenPage> createState() => _ListenPageState(detailList, listenList);
}

class _ListenPageState extends State<ListenPage> {
  Map<String, dynamic> detailList;
  ListenDetails listenList;
  _ListenPageState(this.detailList, this.listenList);

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // for the voice of user
  AudioPlayer audioPlayerA = AudioPlayer();
  AudioPlayer audioPlayerB = AudioPlayer();

  // for the BGM
  AudioPlayer audioPlayerBGM = AudioPlayer();

  ConstantValue constantValue = ConstantValue();

  PlayerState playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    audioPlayerBGM.setVolume(0.4); // Listen to states: playing, paused, stopped
    audioPlayerA.onPlayerStateChanged.listen((PlayerState s) {
      print('Current player state: $s');
      if (!mounted) return;
      setState(() => playerState = s);
    });

    // Listen to audio duration
    audioPlayerA.onDurationChanged.listen((Duration d) {
      //print('Max duration: $d');
      if (!mounted) return;
      setState(() => duration = d);
    });

    // Listen to audio position
    audioPlayerA.onPositionChanged.listen((Duration p) {
      //print('Current position: $p');
      if (!mounted) return;
      setState(() => position = p);
    });

    // Listen when audio complete
    audioPlayerA.onPlayerComplete.listen((event) {
      isPlaying = false;
      if (!mounted) return;
      setState(() {
        position = duration;
      });
    });
  }

  @override
  void dispose() {
    audioPlayerA.dispose();
    audioPlayerB.dispose();
    audioPlayerBGM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late List conversationList = detailList["conversation"].split(",");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          detailList["name"],
          style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF7200),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          padding: EdgeInsets.only(top: constantValue.getScreenHeight(context) / 30, left: 20, right: 20),
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFFF7200),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(detailList["coverimg"]),
                  ),
                ),
              ),
              SizedBox(
                height: constantValue.getScreenHeight(context) / 80,
              ),
              Text(
                "พากย์เสียงโดย ${listenList.userName!}",
                style: GoogleFonts.prompt(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              SizedBox(
                height: constantValue.getScreenHeight(context) / 40,
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: constantValue.getScreenHeight(context) / 2.4, // กรอบบท
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: constantValue.getScreenHeight(context) / 44.5, left: 26, right: 26),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "บทที่ทำการพากย์",
                            style: GoogleFonts.prompt(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: constantValue.getScreenHeight(context) / 49,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: constantValue.getScreenHeight(context) / 15,
                      left: constantValue.getScreenWidth(context) / 43,
                      height: constantValue.getScreenHeight(context) / 3,
                      width: constantValue.getScreenWidth(context) / 1.17, // บท
                      child: Container(
                        height: 360,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFD4B2),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        child: ListView.builder(
                            itemCount: conversationList.length,
                            itemBuilder: (context, index) => ListTile(
                                  title: Text(
                                    conversationList[index],
                                    style: GoogleFonts.prompt(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                      ))
                ],
              ),
              SizedBox(
                height: constantValue.getScreenHeight(context) / 300,
              ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final currentPosition = Duration(seconds: value.toInt());
                  await audioPlayerA.seek(currentPosition);
                  await audioPlayerBGM.seek(currentPosition);
                  if (detailList["voiceoverAmount"] == "2") {
                    await audioPlayerB.seek(currentPosition);
                  }
                },
                activeColor: Colors.orangeAccent,
                inactiveColor: Colors.white,
                label: 'แถบเวลาของเสียงพากย์',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: GoogleFonts.prompt(color: Colors.white),
                    ),
                    Text(
                      formatTime(duration - position),
                      style: GoogleFonts.prompt(color: Colors.white),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: constantValue.getScreenWidth(context) / 16,
                child: IconButton(
                  icon: Icon(
                    size: constantValue.getScreenWidth(context) / 13,
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.orange,
                  ),
                  onPressed: () async {
                    if (isPlaying == false) {
                      startListening();
                    } else {
                      isPlaying = false;
                      pause();
                    }
                  },
                ),
              ),

              SizedBox(
                height: constantValue.getScreenHeight(context) / 30,
              ),
            ],
          )),
    );
  }

  // read audio from database and prepare to play
  Future startListening() async {
    final storageRef = await FirebaseStorage.instance.ref();
    final soundRefA =
        await storageRef.child(listenList.audioFileName!); // <-- your file name
    final soundRefBGM =
        await storageRef.child(detailList["bgmName"]); // <-- your file name
    final metaDataA = await soundRefA.getDownloadURL();
    final metaDataBGM = await soundRefBGM.getDownloadURL();
    log('data: ${metaDataA.toString()}');
    log('data: ${metaDataBGM.toString()}');
    String urlA = metaDataA.toString();
    String urlBGM = metaDataBGM.toString();
    await audioPlayerA.setSourceUrl(urlA);
    await audioPlayerBGM.setSourceUrl(urlBGM);

    if (detailList["voiceoverAmount"] == "2") {
      final soundRefB = await storageRef.child(listenList.audioFileNameBuddy!);
      final metaDataB = await soundRefB.getDownloadURL();
      log('data: ${metaDataB.toString()}');
      String urlB = metaDataB.toString();
      await audioPlayerB.setSourceUrl(urlB);

      isPlaying = true;
      playDuoType(urlA, urlB, urlBGM);
    } else {
      isPlaying = true;
      playSingleType(urlA, urlBGM);
    }
  }

  // play audio of user1, user 2 voice and bgm
  Future playDuoType(String urlA, String urlB, String urlBGM) async {
    audioPlayerA.resume();
    audioPlayerB.resume();
    audioPlayerBGM.resume();
  }

  // play audio of user voice and bgm
  Future playSingleType(String urlA, String urlBGM) async {
    audioPlayerA.resume();
    audioPlayerBGM.resume();
  }

  // pause audio
  Future pause() async {
    await audioPlayerA.pause();
    await audioPlayerBGM.pause();
    if (detailList["voiceoverAmount"] == "2") {
      await audioPlayerB.pause();
    }
  }
}
