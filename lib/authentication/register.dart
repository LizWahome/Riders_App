import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = '';
  String completeAddress = '';

  set location(String location) {}

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }


  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the locatio n services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLocation(Position position) async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      position = newPosition;

    });
    placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark pMark = placeMarks![0];
    completeAddress =
        '${pMark.subThoroughfare}, ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';
    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message: "Please select an image",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        //upload image

        if (nameController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          showDialog(
              context: context,
              builder: ((context) {
                return const LoadingDialog(
                  message: "Registration ongoing",
                );
              }));

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("riders")
              .child(fileName);
          fStorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;
            //save info to firestore
            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return const ErrorDialog(
                  message: "Please fill in the full required information",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                message: "Password do not match",
              );
            });
      }
    }
  }

  Future<void> authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homepage
        Route newRoute = MaterialPageRoute(builder: (context) => const HomeScreen());
        Navigator.push(context, newRoute);
      });
    }
  }

  //save data to Firestore
  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("riders").doc(currentUser.uid).set({
      "riderUID": currentUser.uid,
      "riderEmail": currentUser.email,
      "riderName": nameController.text.trim(),
      "riderAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position?.latitude ??'',
      "lng": position?.longitude ?? '',
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", emailController.text.trim());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              _getImage();
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundColor: Colors.white,
              backgroundImage: imageXFile == null
                  ? null
                  : FileImage(
                      File(imageXFile!.path),
                    ),
              child: imageXFile == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: MediaQuery.of(context).size.width * 0.20,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(children: [
              CustomTextField(
                controller: nameController,
                data: Icons.person,
                hintText: "Name",
                labelText: "Enter your name",
                isObscure: false,
              ),
              CustomTextField(
                controller: emailController,
                data: Icons.email,
                hintText: "Email",
                labelText: "Enter your email",
                isObscure: false,
              ),
              CustomTextField(
                controller: passwordController,
                data: Icons.lock,
                hintText: "Password",
                labelText: "Enter your password",
                isObscure: true,
              ),
              CustomTextField(
                controller: confirmPasswordController,
                data: Icons.lock,
                hintText: "Password",
                labelText: "Confirm password",
                isObscure: true,
              ),
              CustomTextField(
                controller: phoneController,
                data: Icons.phone,
                hintText: "Phone Number",
                labelText: "Enter your phone number",
                isObscure: false,
              ),
              CustomTextField(
                controller: locationController,
                data: Icons.my_location,
                hintText: "My current Address",
                labelText: "Address",
                isObscure: false,
                enabled: false,
              ),
              Container(
                width: 400,
                height: 100,
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Position position = await _getGeoLocationPosition();
                    location =
                        'Lat: ${position.latitude} , Long: ${position.longitude}';
                    getCurrentLocation(position);
                  },
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Get my Current Location",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  formValidation();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 10)),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          )
        ],
      ),
    );
  }
}
