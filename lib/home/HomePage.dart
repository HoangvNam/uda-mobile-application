import 'package:flutter/material.dart';
import 'Components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

// -----------------------------------------------------------------------------

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ccMusic', style: TextStyle(color: Colors.white,),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            // gradient: LinearGradient(
            //   colors: [Colors.lightBlueAccent, Colors.blueAccent],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // )
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: 'Explore',),
            Tab(icon: Icon(Icons.trending_up_outlined), text: 'Trend',),
            Tab(icon: Icon(Icons.favorite), text: 'Favorite',),
            Tab(icon: Icon(Icons.person), text: 'Profile',),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.lightGreenAccent,
          indicatorWeight: 2.0,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreen(),
          MusicLibraryScreen(),
          FavoriteScreen(),
          ProfileScreen()
        ],
      ),
    );
  }
}