import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';



class MusicInstance extends StatefulWidget {
  final String? audio, image, name, singer, time;
  final AudioPlayer iAudioPlayer;
  final Function(String) onPlay;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const MusicInstance({
    super.key,
    required this.audio,
    required this.image,
    required this.name,
    this.singer,
    required this.time,
    required this.iAudioPlayer,
    required this.onPlay,
    required this.isPlaying,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  MusicInstanceState createState() => MusicInstanceState();
}


class MusicInstanceState extends State<MusicInstance> {

  void _handleTap() {
    widget.onPlay(widget.audio!);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _handleTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  widget.image!,
                  height: 0.08 * screenHeight, width: 0.08 * screenHeight,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 0.08 * screenWidth),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name!),
                  Text(widget.singer!),
                  SizedBox(height: 0.01 * screenHeight),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      SizedBox(width: 0.01 * screenWidth),
                      Text(widget.time!),
                    ],
                  ),
                ],
              ),
              const Spacer(flex: 1),
              IconButton(
                icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: widget.onFavoriteToggle,
              ),
              Icon(widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class MusicBottomShow extends StatefulWidget {
  final String name;
  final String singer;
  final String audio;
  final bool isPlaying;
  final Function onPlayPause;

  const MusicBottomShow({
    super.key,
    required this.name,
    required this.singer,
    required this.audio,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  State<StatefulWidget> createState() {
    return MusicBottomShowState();
  }
}

class MusicBottomShowState extends State<MusicBottomShow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.singer,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 36.0,
            ),
            onPressed: () => widget.onPlayPause(widget.audio),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------