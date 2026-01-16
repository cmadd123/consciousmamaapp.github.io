import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';

List<dynamic> listOfMessagesToListOfJson(List<MessagesRecord>? messages) {
  if (messages == null) return [];

  final reverseMessages = messages.reversed.toList();
  final List<Map<String, dynamic>> jsonList = reverseMessages.map((message) {
    return {
      'role':
          message.role.toString().split('.').last, // Ensure correct extraction
      'content': message.content,
    };
  }).toList();

  return jsonList;
}

int getLastIndexInMessages(List<MessagesForSteamStruct>? listOfMessages) {
  // i want to get the last index of the list
  if (listOfMessages != null && listOfMessages.isNotEmpty) {
    return listOfMessages.length - 1;
  } else {
    return 0;
  }
}

double getAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int years = today.year - birthDate.year;
  int months = today.month - birthDate.month;
  int days = today.day - birthDate.day;

  double age = years.toDouble();

  if (months < 0 || (months == 0 && days < 0)) {
    age -= 1;
    months += 12;
  }

  double decimalPart = months / 12;
  return double.parse((age + decimalPart).toStringAsFixed(1));
}

List<DocumentReference>? gettwoRandomActivity(
    List<DocumentReference>? activitiesOrg) {
  // return 3 random values from argument activites  as  list
  if (activitiesOrg == null || activitiesOrg.isEmpty) {
    return null;
  }

  final List<DocumentReference> activities = List.from(activitiesOrg);
  activities.shuffle();

  if (activities.length <= 2) {
    return activities;
  } else {
    return activities.sublist(0, 2);
  }
}

double newCobverBirthdayToAGe(DateTime birthDate) {
  // return the age in years as a double
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;
  if (currentDate.month < birthDate.month ||
      (currentDate.month == birthDate.month &&
          currentDate.day < birthDate.day)) {
    age--;
  }
  return age.toDouble();
}

List<DocumentReference>? getThreeRandomActivity(
    List<DocumentReference>? activitiesOrg) {
  // return 3 random values from argument activites  as  list
  if (activitiesOrg == null || activitiesOrg.isEmpty) {
    return null;
  }

  final List<DocumentReference> activities = List.from(activitiesOrg);
  activities.shuffle();

  if (activities.length <= 3) {
    return activities;
  } else {
    return activities.sublist(0, 3);
  }
}

List<HomeActivtyModelStruct>? convertModel(
    List<ChildActivityStruct>? orgModel) {
  if (orgModel == null) return null;

  return orgModel.expand((childActivity) {
    final childRef =
        childActivity.userchilde; // Ensure this matches your schema field name
    final activities = childActivity.activity
            ?.whereType<DocumentReference>() // Filter valid references
            .take(2) // Take only first 2 activities
            .toList() ??
        []; // Convert to list or fallback to empty

    return activities.map((singleActivity) => HomeActivtyModelStruct(
          childRef: childRef,
          actitvtyRef:
              singleActivity, // Ensure this matches your schema field name
        ));
  }).toList();
}

bool? checkChildreanName(
  List<ChildernRecord>? childrean,
  String name,
) {
  // return typ boolean depend on the name if childrean firebase record name in the list list return true else return false
  if (childrean != null) {
    return childrean.any((child) => child.name == name);
  } else {
    return false;
  }
}

String? getinstructionForChildren(List<ChildernRecord>? children) {
  // I want to returnn some this like  Hamza (with id : ), Hana (whith id : )
  if (children == null || children.isEmpty) {
    return null;
  }

  String result = '';
  for (int i = 0; i < children.length; i++) {
    print("chile");
    print(children[i].reference.id);
    result +=
        '${children[i].name} (with birth date: ${children[i].birthDay}), ';
  }

  return result.substring(
      0, result.length - 2); // remove the last comma and space
}

String? getFullMessage(List<String>? allMessages) {
  // concat all message in one respect /n and spaces exetra
  if (allMessages == null || allMessages.isEmpty) {
    return null;
  }

  return allMessages.join('');
}

int getCurrentIndex(List<ChatCompletioninputItemStruct> list) {
  if (list != null && list.isNotEmpty) {
    return list.length - 1;
  } else {
    return 0;
  }
}

List<dynamic>? convertDatatype(List<ChatCompletioninputItemStruct>? data) {
  // convert data type to json
  if (data == null) {
    return null;
  }

  return data.map((item) {
    return {
      'role': item.role ?? "user",
      'content': item.content ?? "",
    };
  }).toList();
}

List<ChatCompletioninputItemStruct>? reverseList(
    List<ChatCompletioninputItemStruct>? data) {
  // reverse the list
  if (data == null) {
    return null;
  }

  return List<ChatCompletioninputItemStruct>.from(data.reversed);
}

String getTimeOfDay(DateTime dateTime) {
  int hour = dateTime.hour;

  if (hour >= 5 && hour < 12) {
    return "morning";
  } else if (hour >= 12 && hour < 18) {
    return "afternoon";
  } else if (hour >= 18 && hour < 22) {
    return "evening";
  } else {
    return "night";
  }
}

List<DateTime>? getSevenDays() {
  DateTime now = DateTime.now();
  return List<DateTime>.generate(7, (index) => now.add(Duration(days: index)));
}

String? convertTOImage(String? stringImage) {
  return stringImage;
}

bool? compareTime(
  DateTime? currentDate,
  DateTime? endDate,
) {
  // i want to compare btween the two dates if currentDate greater than endDate return false elce true
  if (currentDate == null || endDate == null) {
    return null; // Return null if either date is null
  }
  return currentDate.isBefore(
      endDate); // Return true if currentDate is before endDate, otherwise false
}

double? formatNumbers(double? doubleNumber) {
  // format doubleNumber like 4.5554410 to 4.5 or 3.144541 to 3.1
  if (doubleNumber == null) return null;
  return double.parse(doubleNumber.toStringAsFixed(1));
}

String? getTimeFormatiedWithTodayString(DateTime? date) {
  if (date == null) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final givenDate = DateTime(date.year, date.month, date.day);

  if (givenDate == today) {
    return "Today";
  } else if (givenDate == today.add(Duration(days: 1))) {
    return "Tomorrow";
  } else {
    return DateFormat('EEE, d').format(date);
    // Example: Fri, 3
  }
}

DateTime? currentUTCTime(DateTime dataePicked) {
  return dataePicked.toUtc();
}
