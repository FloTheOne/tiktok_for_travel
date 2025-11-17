import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_travel/controllers/auth_controller.dart';
import 'package:tiktok_travel/views/screens/add_video_screen.dart';
import 'package:tiktok_travel/views/screens/profile_screen.dart';
import 'package:tiktok_travel/views/screens/video_screen.dart';

const String apiKey = "#";
//
List pages = [
  VideoScreen(),
  Text('Search Screen'),
  const AddVideoScreen(),
  Text('Messages Screen'),
  ProfileScreen(uid: authCotroller.user.uid),
];

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

//Controler
var authCotroller = AuthController.instance;

//
const List<String> dropDownList = <String>[
  'Things To Do',
  'Places',
  'Restaurants',
  'Hotels',
  'Tips',
];
