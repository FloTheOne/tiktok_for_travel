import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:tiktok_travel/constants.dart';
import 'package:tiktok_travel/controllers/upload_controller.dart';
import 'package:tiktok_travel/models/drop_down.dart';
import 'package:tiktok_travel/models/location_prediction/autocomplete_prediction.dart';
import 'package:tiktok_travel/models/location_prediction/location_tile.dart';
import 'package:tiktok_travel/models/location_prediction/network_utiliti.dart';
import 'package:tiktok_travel/models/location_prediction/place_auto_complete_response.dart';
import 'package:tiktok_travel/views/widgets/text_input_field.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  const ConfirmScreen({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late VideoPlayerController controller;
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _typeOfActivity = TextEditingController();
  double _rating = 0;
  double _latitude = 0;
  double _longitude = 0;

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());

  List<AutocompletePrediction> placePredictions = [];

  void placeAutoComplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": apiKey,
    });
    String? response = await NetworkUtiliti.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        placePredictions = result.predictions!;
      }
    }
  }

  Future<String> fetchPlaceId(String input, String apiKey) async {
    final response = await http.get(Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {'input': input, 'key': apiKey},
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'OK' &&
          responseData['predictions'].isNotEmpty) {
        // Extract place_id from the first prediction
        return responseData['predictions'][0]['place_id'];
      } else {
        // No predictions found or API status is not OK
        throw Exception('No place ID found for $input');
      }
    } else {
      // Error occurred while fetching predictions
      throw Exception('Failed to fetch place predictions');
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(
      String placeId, String apiKey) async {
    final response = await http.get(Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {'place_id': placeId, 'key': apiKey},
    ));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void getLatAndLng(String selectedLocation) async {
    final String placeId = await fetchPlaceId(selectedLocation, apiKey);
    final Map<String, dynamic> placeDetails =
        await fetchPlaceDetails(placeId, apiKey);
    final double latitude =
        placeDetails['result']['geometry']['location']['lat'];
    final double longitude =
        placeDetails['result']['geometry']['location']['lng'];
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
    print('Longitude 2.0 + $_longitude');
    print('Latitude 2.0+ $_latitude');
  }

  void handleLocationSelected(String selectedLocation) {
    setState(() {
      _locationController.text = selectedLocation;
      getLatAndLng(selectedLocation);
      placePredictions.clear(); // Clear suggestions
    });
    // Perform autocomplete using the selected location
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.5,
              child: VideoPlayer(controller),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          liveLocation();
                          getCurrentLocation().then((value) {
                            print('rating + ${_rating}');
                            print('selected + ${_typeOfActivity.text}');
                            print('Longitude 1.0 + ${value.latitude}');
                            print('Latitude 1.0+ ${value.longitude}');
                            _latitude = value.latitude;
                            _longitude = value.longitude;
                          });
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text("my location"),
                      ),
                    ),
                    const DropdownMenuExample(),
                    const SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _rating = rating;
                        print(rating);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextInputField(
                        controller: _songNameController,
                        labelText: 'Song',
                        icon: Icons.music_note,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextInputField(
                        controller: _captionController,
                        labelText: 'Caption Name',
                        icon: Icons.closed_caption,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        onChanged: (value) {
                          placeAutoComplete(value);
                        },
                        textInputAction: TextInputAction.search,
                        controller: _locationController,
                        decoration: const InputDecoration(
                            hintText: 'Search For Location'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          _typeOfActivity.text =
                              DropdownMenuExample.selectedCategory;
                        }),
                        uploadVideoController.uploadVideo(
                          _songNameController.text,
                          _captionController.text,
                          widget.videoPath,
                          _typeOfActivity.text,
                          _latitude,
                          _longitude,
                          _rating,
                        ),
                      },
                      child: const Text(
                        'Share!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: placePredictions.length,
                      itemBuilder: (context, index) => LocationListTile(
                        location: placePredictions[index].description!,
                        press: () {
                          handleLocationSelected(
                              placePredictions[index].description!);
                        },
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
