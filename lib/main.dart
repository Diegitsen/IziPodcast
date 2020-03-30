import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

final url = 'https://itsallwidgets.com/podcast/feed';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DashCast',
      home: EpisodesPage(),
    );
  }
}

class EpisodesPage extends StatelessWidget {
  const EpisodesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: http.get(url),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          final response = snapshot.data;
          if (response.statusCode == 200) {
            final rssString = response.body;
            var rssFeed = RssFeed.parse(rssString);
            return EpisodeListView(rssFeed: rssFeed);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        } else {}
      },
    ));
  }
}

class EpisodeListView extends StatelessWidget {
  const EpisodeListView({
    Key key,
    @required this.rssFeed,
  }) : super(key: key);

  final RssFeed rssFeed;

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: rssFeed.items
            .map(
              (i) => ListTile(
                title: Text(i.title),
                subtitle: Text(
                  i.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(item: i),
                    ),
                  );
                },
              ),
            )
            .toList());
  }
}

class PlayerPage extends StatelessWidget {
  PlayerPage({this.item});

  final RssItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Center(
        child: SafeArea(child: Player()),
      ),
    );
  }
}

class Player extends StatelessWidget {
  const Player({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Flexible(
        child: Placeholder(),
        flex: 8,
      ),
      Flexible(
        flex: 2,
        child: AudioControls(),
      )
    ]);
  }
}

class AudioControls extends StatelessWidget {
  const AudioControls({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [PlaybackButtons()],
    );
  }
}

class PlaybackButtons extends StatelessWidget {
  const PlaybackButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [PlaybackButton()],
    );
  }
}

class PlaybackButton extends StatefulWidget {
  const PlaybackButton({Key key}) : super(key: key);

  @override
  _PlaybackButtonState createState() => _PlaybackButtonState();
}

class _PlaybackButtonState extends State<PlaybackButton> {
  bool _isPlaying = false;
  FlutterSound _sound;
  final url =
      'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Surf%20Shimmy.mp3';
  double _playPosition;
  Stream<PlayStatus> _playerSubscription;

  @override
  void initState() {
    super.initState();
    _sound = FlutterSound();
    _playPosition = 0;
  }

  void _stop() async {
    await _sound.stopPlayer();
    setState(() => _isPlaying = false);
  }

  void _play() async {
    await _sound.startPlayer(url);

    _playerSubscription = _sound.onPlayerStateChanged
      ..listen((e) {
        if (e != null) {
          setState(() => _playPosition = (e.currentPosition / e.duration));
        }
      });
    setState(() => _isPlaying = true);
  }

  void _fastForward() {}

  void _rewind() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Slider(value: _playPosition),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(icon: Icon(Icons.fast_rewind), onPressed: null),
            IconButton(
              icon: _isPlaying ? Icon(Icons.stop) : Icon(Icons.play_arrow),
              onPressed: () {
                if (_isPlaying) {
                  _stop();
                } else {
                  _play();
                }
              },
            ),
            IconButton(icon: Icon(Icons.fast_forward), onPressed: null)
          ],
        ),
      ],
    );
  }
}
