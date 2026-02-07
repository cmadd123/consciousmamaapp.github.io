import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Holds demo data (child + parents) entered before account creation
/// This data is saved to Firestore after signup succeeds
class DemoDataNotifier extends ChangeNotifier {
  // Child data
  String? childName;
  DateTime? childBirthdate;
  String? childGender;

  // Parent data
  String? myName;
  Color? myColor;
  String? partnerName;
  Color? partnerColor;

  /// Save child info
  void setChildInfo({
    required String name,
    required DateTime birthdate,
    String? gender,
  }) {
    childName = name;
    childBirthdate = birthdate;
    childGender = gender;
    notifyListeners();
  }

  /// Save parent info
  void setParentInfo({
    String? myNameValue,
    Color? myColorValue,
    String? partnerNameValue,
    Color? partnerColorValue,
  }) {
    myName = myNameValue;
    myColor = myColorValue;
    partnerName = partnerNameValue;
    partnerColor = partnerColorValue;
    notifyListeners();
  }

  /// Check if child data exists
  bool hasChildData() {
    return childName != null && childBirthdate != null;
  }

  /// Save demo data to Firestore (called after successful signup)
  Future<void> saveToFirestore() async {
    final userId = currentUserUid;
    if (userId.isEmpty || !hasChildData()) {
      return; // No user or no data to save
    }

    try {
      // Save child data
      await FirebaseFirestore.instance.collection('childern').add({
        'name': childName,
        'birthday': childBirthdate,
        'gender': childGender,
        'color': myColor != null ? '#${myColor!.value.toRadixString(16).substring(2)}' : null,
        'user_ref': FirebaseFirestore.instance.doc('users/$userId'),
        'created_time': FieldValue.serverTimestamp(),
      });

      // Save user profile data (parent names/colors) - update user document
      if (myName != null || partnerName != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          if (myName != null) 'display_name': myName,
          // Add other parent fields as needed based on your schema
        });
      }

      // Clear data after successful save
      clear();
    } catch (e) {
      print('Error saving demo data to Firestore: $e');
      // Don't clear data if save failed
    }
  }

  /// Clear all data (after successful save to Firestore)
  void clear() {
    childName = null;
    childBirthdate = null;
    childGender = null;
    myName = null;
    myColor = null;
    partnerName = null;
    partnerColor = null;
    notifyListeners();
  }
}
