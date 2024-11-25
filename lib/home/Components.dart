import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../music/Music.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> singers = [];

  Future<void> fetchSingers() async {
    final response =
    await http.get(Uri.parse('https://uda-mobile-server.onrender.com/get-singers'));
    if (response.statusCode == 200) {
      setState(() {
        singers = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSingers();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(2.5),
          height: 0.08 * screenHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blue[500]
          ),
          child: Row(
            children: [
              const Text(
                'Singers',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 0.02 * screenWidth,),
              const Icon(Icons.music_note, color: Colors.white, size: 22,)
            ],
          ),
        ),
        Column(
          children: List.generate(singers.length, (index) {
            final singer = singers[index];
            return SingerCard(
                avatar: singer['avatar'],
                name: singer['name'],
                numberSongs: singer['numberSongs']
            );
          }),
        ),
        SizedBox(height: 0.01 * screenHeight,),
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(2.5),
          height: 0.08 * screenHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blue[500]
          ),
          child: Row(
            children: [
              const Text(
                'Playlists',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 0.02 * screenWidth,),
              const Icon(Icons.playlist_play, color: Colors.white, size: 22,)
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.25
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return PlaylistCard(
                  title: 'Playlist ${index + 1}',
                  coverImage: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkXqjXQGt-nkQ-TUMKnsEEDnUd7Fa_Shj55Q&s'
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final String title;
  final String coverImage;
  const PlaylistCard({
    super.key,
    required this.title,
    required this.coverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              coverImage,
              height: 100.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingerCard extends StatelessWidget {
  final String avatar, name;
  final int numberSongs;
  const SingerCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.numberSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                avatar,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      'Songs: $numberSongs',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.music_note_outlined,
                      color: Colors.blueAccent,
                      size: 16.0,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class MusicLibraryScreen extends StatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  MusicLibraryScreenState createState() => MusicLibraryScreenState();
}

class MusicLibraryScreenState extends State<MusicLibraryScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentPlayingAudio;
  bool isPlaying = false;
  int initialSongsCount = 8;
  List<Map<String, dynamic>> songs = [];
  List<dynamic> favoriteSongs = [];

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> fetchSongs() async {
    final response =
    await http.get(Uri.parse('https://uda-mobile-server.onrender.com/get-songs'));
    if (response.statusCode == 200) {
      setState(() {
        songs = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load songs');
    }
  }

  Future<void> fetchUserFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://uda-mobile-server.onrender.com/get-favorite-songs/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> favorites = data['favorites'];

        setState(() {
          favoriteSongs = favorites.map((song) => song['_id']).toList();
        });
      } else {
        throw Exception('Failed to fetch favorites');
      }
    } catch (error) {
      print('Error fetching favorites: $error');
    }
  }

  bool isFavorite(String songId) {
    return favoriteSongs.contains(songId);
  }

  Future<void> addFavorite(String userId, String songId) async {
    final response = await http.post(
      Uri.parse('https://uda-mobile-server.onrender.com/favorite-song'),
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        favoriteSongs.add(songId);
      });
    } else {
      throw Exception('Failed to add favorite song');
    }
  }

  Future<void> removeFavorite(String userId, String songId) async {
    final response = await http.delete(
      Uri.parse('https://uda-mobile-server.onrender.com/favorite-song'),
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        favoriteSongs.remove(songId);
      });
    } else {
      throw Exception('Failed to remove favorite song');
    }
  }

  void toggleFavorite(String songId) async {
    final userId = await getUserId();
    if (userId != null) {
      try {
        if (isFavorite(songId)) {
          await removeFavorite(userId, songId);
        } else {
          await addFavorite(userId, songId);
        }
      } catch (e) {
        print("Error toggling favorite: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use this feature')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSongs();
    getUserId().then((userId) {
      if (userId != null) {
        fetchUserFavorites(userId);
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void playAudio(String audio) async {
    if (currentPlayingAudio != null && currentPlayingAudio != audio) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    }

    if (currentPlayingAudio == audio && isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      setState(() {
        currentPlayingAudio = audio;
        isPlaying = true;
      });
      await audioPlayer.play(AssetSource(audio));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(2.5),
          height: 0.08 * screenHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blue[500]
          ),
          child: Row(
            children: [
              const Text(
                'Trend',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 0.02 * screenWidth,),
              const Icon(Icons.trending_up, color: Colors.white, size: 22,)
            ],
          ),
        ),
        Expanded(
          child: songs.isNotEmpty
              ? ListView(
            children: List.generate(
              initialSongsCount.clamp(0, songs.length),
                  (index) {
                final song = songs[index];
                return MusicInstance(
                  audio: song['audio'],
                  image: song['image'],
                  name: song['name'],
                  singer: song['singer'],
                  time: song['time'],
                  iAudioPlayer: audioPlayer,
                  onPlay: playAudio,
                  isPlaying:
                  currentPlayingAudio == song['audio'] && isPlaying,
                  isFavorite: isFavorite(song['_id']),
                  onFavoriteToggle: () => toggleFavorite(song['_id']),
                );
              },
            ),
          )
              : const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        if (currentPlayingAudio != null)
          Positioned(
            bottom: 0.002 * screenHeight,
            left: 0,
            right: 0,
            child: MusicBottomShow(
              name: songs.firstWhere(
                      (song) => song['audio'] == currentPlayingAudio)['name'],
              singer: songs.firstWhere(
                      (song) => song['audio'] == currentPlayingAudio)['singer'],
              audio: currentPlayingAudio!,
              isPlaying: isPlaying,
              onPlayPause: playAudio,
            ),
          )
      ],
    );
  }
}

// -----------------------------------------------------------------------------

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentPlayingAudio;
  bool isPlaying = false;
  bool isLoading = true;
  int initialSongsCount = 5;
  List<dynamic> favoriteSongs = [];
  List<dynamic> checkFavoriteSongs = [];

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> fetchFavoriteSongs(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://uda-mobile-server.onrender.com/get-favorite-songs/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          favoriteSongs = List<Map<String, dynamic>>.from(data['favorites']);
          checkFavoriteSongs = data['favorites'].map((song) => song['_id']).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch favorite songs');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isFavorite(String songId) {
    return checkFavoriteSongs.contains(songId);
  }

  Future<void> addFavorite(String userId, String songId) async {
    final response = await http.post(
      Uri.parse('https://uda-mobile-server.onrender.com/favorite-song'),
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        checkFavoriteSongs.add(songId);
      });
    } else {
      throw Exception('Failed to add favorite song');
    }
  }

  Future<void> removeFavorite(String userId, String songId) async {
    final response = await http.delete(
      Uri.parse('https://uda-mobile-server.onrender.com/favorite-song'),
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        checkFavoriteSongs.remove(songId);
      });
    } else {
      throw Exception('Failed to remove favorite song');
    }
  }

  void toggleFavorite(String songId) async {
    final userId = await getUserId();
    if (userId != null) {
      try {
        if (isFavorite(songId)) {
          await removeFavorite(userId, songId);
        } else {
          await addFavorite(userId, songId);
        }
      } catch (e) {
        print("Error toggling favorite: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use this feature')),
      );
    }
  }

  void playAudio(String audio) async {
    if (currentPlayingAudio != null && currentPlayingAudio != audio) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    }

    if (currentPlayingAudio == audio && isPlaying) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      setState(() {
        currentPlayingAudio = audio;
        isPlaying = true;
      });
      await audioPlayer.play(AssetSource(audio));
    }
  }

  @override
  void initState() {
    super.initState();
    getUserId().then((userId) {
      if (userId != null) {
        fetchFavoriteSongs(userId);
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(2.5),
          height: 0.08 * screenHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.blue[500]
          ),
          child: Row(
            children: [
              const Text(
                'Favorite',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 0.02 * screenWidth),
              const Icon(Icons.favorite, color: Colors.white, size: 22),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : favoriteSongs.isNotEmpty
              ? ListView(
            children: List.generate(
              initialSongsCount.clamp(0, favoriteSongs.length),
                  (index) {
                final song = favoriteSongs[index];
                return MusicInstance(
                  audio: song['audio'],
                  image: song['image'],
                  name: song['name'],
                  singer: song['singer'],
                  time: song['time'],
                  iAudioPlayer: audioPlayer,
                  onPlay: playAudio,
                  isPlaying:
                  currentPlayingAudio == song['audio'] && isPlaying,
                  isFavorite: isFavorite(song['_id']),
                  onFavoriteToggle: () => toggleFavorite(song['_id']),
                );
              },
            ),
          )
              : const Center(
            child: Text(
              'No favorite songs yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
        if (currentPlayingAudio != null)
          Positioned(
            bottom: 0.002 * screenHeight,
            left: 0,
            right: 0,
            child: MusicBottomShow(
              name: favoriteSongs.firstWhere(
                      (song) => song['audio'] == currentPlayingAudio)['name'],
              singer: favoriteSongs.firstWhere(
                      (song) => song['audio'] == currentPlayingAudio)['singer'],
              audio: currentPlayingAudio!,
              isPlaying: isPlaying,
              onPlayPause: playAudio,
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  // final String name;

  const ProfileScreen({
    super.key,
  });

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationsEnabled = false;
  String name = '';

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  void initState() {
    super.initState();
    getUsername().then((username) {
      if (username != null) {
        setState(() {
          name = username;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue[500]
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 0.075 * screenWidth,
                  backgroundImage: const AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Music',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Thêm logic chỉnh sửa hồ sơ
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[300],
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: isNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  isNotificationsEnabled = !isNotificationsEnabled;
                });
              },
              activeColor: Colors.lightBlueAccent,
              activeTrackColor: Colors.greenAccent,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // None
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy & Policies'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // None
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // None
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Usage'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // None
            },
          ),
          SizedBox(
            height: 0.04 * screenHeight,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                padding: EdgeInsets.symmetric(
                    horizontal: 0.08 * screenHeight,
                    vertical: 0.015 * screenHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'LOGIN IN/OUT',
              style: TextStyle(color: Colors.white),

            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
