import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Data class for a single child
class ChildData {
  final String name;
  final DateTime birthdate;
  final String? gender;
  final Color? color;

  ChildData({
    required this.name,
    required this.birthdate,
    this.gender,
    this.color,
  });
}

/// Holds demo data (children + parents) entered before account creation
/// This data is saved to Firestore after signup succeeds
class DemoDataNotifier extends ChangeNotifier {
  // Multiple children support
  List<ChildData> children = [];

  // Legacy single-child accessors for backward compatibility
  String? get childName => children.isNotEmpty ? children.first.name : null;
  DateTime? get childBirthdate => children.isNotEmpty ? children.first.birthdate : null;
  String? get childGender => children.isNotEmpty ? children.first.gender : null;

  // Parent data
  String? myName;
  Color? myColor;
  String? partnerName;
  Color? partnerColor;

  /// Add a child to the list
  void addChild({
    required String name,
    required DateTime birthdate,
    String? gender,
    Color? color,
  }) {
    children.add(ChildData(
      name: name,
      birthdate: birthdate,
      gender: gender,
      color: color,
    ));
    notifyListeners();
  }

  /// Save child info (legacy - replaces first child or adds if empty)
  void setChildInfo({
    required String name,
    required DateTime birthdate,
    String? gender,
  }) {
    if (children.isEmpty) {
      children.add(ChildData(name: name, birthdate: birthdate, gender: gender));
    } else {
      children[0] = ChildData(name: name, birthdate: birthdate, gender: gender);
    }
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
    return children.isNotEmpty;
  }

  /// Save demo data to Firestore (called after successful signup)
  Future<void> saveToFirestore() async {
    final userId = currentUserUid;
    if (userId.isEmpty || !hasChildData()) {
      return; // No user or no data to save
    }

    try {
      // Save all children
      for (final child in children) {
        await FirebaseFirestore.instance.collection('childern').add({
          'name': child.name,
          'birthday': child.birthdate,
          'gender': child.gender,
          'color': child.color != null ? '#${child.color!.value.toRadixString(16).substring(2)}' : null,
          'user_ref': FirebaseFirestore.instance.doc('users/$userId'),
          'created_time': FieldValue.serverTimestamp(),
        });
      }

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
    children.clear();
    myName = null;
    myColor = null;
    partnerName = null;
    partnerColor = null;
    notifyListeners();
  }
}
