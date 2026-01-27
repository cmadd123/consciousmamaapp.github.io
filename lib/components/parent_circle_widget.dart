import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// Default colors for parents (used when user hasn't set custom colors)
const Color kDefaultMyColor = Color(0xFFEC407A); // Pink
const Color kDefaultPartnerColor = Color(0xFF1976D2); // Blue

/// Helper class to get parent display info from user record
class ParentDisplayInfo {
  final String myName;
  final String myInitial;
  final Color myColor;
  final String partnerName;
  final String partnerInitial;
  final Color partnerColor;

  ParentDisplayInfo({
    required this.myName,
    required this.myInitial,
    required this.myColor,
    required this.partnerName,
    required this.partnerInitial,
    required this.partnerColor,
  });

  /// Create from a UsersRecord
  factory ParentDisplayInfo.fromUser(UsersRecord? user) {
    final myName = user?.myName ?? 'Me';
    final partnerName = user?.partnerName.isNotEmpty == true ? user!.partnerName : 'Partner';

    return ParentDisplayInfo(
      myName: myName,
      myInitial: myName.isNotEmpty ? myName[0].toUpperCase() : 'M',
      myColor: user?.myColor != null ? Color(user!.myColor!) : kDefaultMyColor,
      partnerName: partnerName,
      partnerInitial: partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'P',
      partnerColor: user?.partnerColor != null ? Color(user!.partnerColor!) : kDefaultPartnerColor,
    );
  }

  /// Default fallback info
  factory ParentDisplayInfo.defaults() {
    return ParentDisplayInfo(
      myName: 'Me',
      myInitial: 'M',
      myColor: kDefaultMyColor,
      partnerName: 'Partner',
      partnerInitial: 'P',
      partnerColor: kDefaultPartnerColor,
    );
  }
}

/// Widget that displays a parent circle (Me or Partner)
/// Automatically fetches colors from current user's record
class ParentCircleWidget extends StatelessWidget {
  final bool isMe; // true = current user, false = partner
  final double size;
  final double fontSize;
  final double borderWidth;
  final Color borderColor;

  const ParentCircleWidget({
    super.key,
    required this.isMe,
    this.size = 26.0,
    this.fontSize = 11.0,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsersRecord>(
      stream: currentUserReference != null
          ? UsersRecord.getDocument(currentUserReference!)
          : null,
      builder: (context, snapshot) {
        final info = snapshot.hasData
            ? ParentDisplayInfo.fromUser(snapshot.data)
            : ParentDisplayInfo.defaults();

        final color = isMe ? info.myColor : info.partnerColor;
        final initial = isMe ? info.myInitial : info.partnerInitial;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A static version that takes colors directly (for use in lists where
/// we don't want multiple stream builders)
class ParentCircleStatic extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;
  final double fontSize;
  final double borderWidth;
  final Color borderColor;

  const ParentCircleStatic({
    super.key,
    required this.initial,
    required this.color,
    this.size = 26.0,
    this.fontSize = 11.0,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Mixin to easily get parent info in any widget
mixin ParentInfoMixin<T extends StatefulWidget> on State<T> {
  ParentDisplayInfo? _parentInfo;

  ParentDisplayInfo get parentInfo => _parentInfo ?? ParentDisplayInfo.defaults();

  /// Call this in initState or when user data is available
  Future<void> loadParentInfo() async {
    if (currentUserReference == null) return;

    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }
}
