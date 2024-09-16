import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_m/screens/splash_screen.dart';
import 'package:weather_m/services/api_methods.dart';

import 'package:weather_m/utils/colors.dart';
import 'package:weather_m/widgets/detail_card.dart';

import '../provider/location_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userLocation;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initializeLocation();
  }

  //load user location
  Future<void> _loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLocation = prefs.getString('location');
    });
  }

//get the initial location of the user from provider
  Future<void> _initializeLocation() async {
    // Schedule the location update after the current build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.updateLocation();
      await locationProvider.loadSavedLocation();
      _loadUserLocation();
    });
  }

  // Save the user location to shared preferences
  Future<void> _saveUserLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('location', location); // Store the new location

    setState(() {
      userLocation = location;
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //height and width define
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;

    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Today',
          style: GoogleFonts.anton(fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              //reset the skip pressed button
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setBool('skipPressed', false);

              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()));
            },
            icon: const Icon(Icons.help),
            iconSize: 30,
          )
        ],
      ),
      body: locationProvider.isLoading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Loading Location'),
                CircularProgressIndicator(),
              ],
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * .02),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: userLocation != null &&
                                      userLocation!.isNotEmpty
                                  ? userLocation
                                  : 'Enter place name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * .02,
                        ),
                        SizedBox(
                          height: height * .068,
                          child: ElevatedButton(
                              onPressed: () async {
                                final location = searchController.text;
                                if (location.isNotEmpty) {
                                  FocusScope.of(context).unfocus();
                                  await _saveUserLocation(location);
                                  setState(() {});

                                  // Save location
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: userLocation != null &&
                                      userLocation!.isNotEmpty
                                  ? const Text('Update')
                                  : Text(
                                      'Save',
                                      style: GoogleFonts.lora(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    )),
                        )
                      ],
                    ),
                    FutureBuilder(
                      future: ApiMethods().getWeather(userLocation != null &&
                              userLocation!.isNotEmpty
                          ? userLocation!
                          : '${locationProvider.latitude},${locationProvider.longitude}'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              SizedBox(
                                height: height * .3,
                              ),
                              const Center(
                                  child: Text('Please enter valid location')),
                            ],
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        } else {
                          // Ensure the URL is correctly formatted
                          String imageUrl =
                              snapshot.data!.current!.condition!.icon!;
                          if (!imageUrl.startsWith('http://') &&
                              !imageUrl.startsWith('https://')) {
                            imageUrl = 'https:$imageUrl';
                          }

                          return Padding(
                            padding: EdgeInsets.only(top: height * .03),
                            child: Column(
                              children: [
                                //weather detail part
                                SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 10,
                                    child: Padding(
                                      padding: EdgeInsets.all(width * .04),
                                      child: Column(
                                        children: [
                                          Text(
                                            snapshot.data!.location!.name!,
                                            style: const TextStyle(
                                              fontSize: 26,
                                            ),
                                          ),
                                          Text(
                                            '${snapshot.data!.current!.tempC}° C',
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Image(image: NetworkImage(imageUrl)),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            snapshot.data!.current!.condition!
                                                .text!,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: height * .03,
                                ),

                                //additional detail widgets
                                Text(
                                  'Additional Detail',
                                  style: GoogleFonts.anton(
                                      fontSize: 22, letterSpacing: 1.5),
                                ),
                                Row(
                                  children: [
                                    DetailCard(
                                        text: 'Humidity',
                                        data: snapshot.data!.current!.humidity
                                            .toString(),
                                        icon: Icons.water_drop),
                                    DetailCard(
                                        text: 'Wind',
                                        data: snapshot.data!.current!.windKph
                                            .toString(),
                                        icon: Icons.air),
                                    DetailCard(
                                        text: 'Pressure',
                                        data: snapshot.data!.current!.pressureIn
                                            .toString(),
                                        icon: Icons.water)
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
