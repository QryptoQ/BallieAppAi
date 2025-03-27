import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../services/database.dart';
import '../widgets/user_avatar.dart';
import './stats.dart';
import './skills.dart';

class Player implements Comparable {
  final int userId;
  final String name;
  String? photoUrl;
  String? headerPhoto;
  PlayerRole? role;
  int? presentPercentage;
  Stats? stats;
  Skills? skills;
  PlayerPosition? primaryPosition;
  PlayerPosition? secondaryPosition;
  double? rating;
  int? statusUpcomingMatch;
  DateTime? eventStatusUpdatedAt;
  String? absentReason;

  Player(
      {required this.userId,
      required this.name,
      this.photoUrl,
      this.headerPhoto,
      this.role,
      this.presentPercentage,
      this.skills,
      this.stats,
      this.primaryPosition,
      this.secondaryPosition,
      this.rating,
      this.statusUpcomingMatch,
      this.absentReason,
      this.eventStatusUpdatedAt});

  Widget userAvatar({double fontSize = 28.0, double radius = 24.0}) {
    return UserAvatar(
      id: userId,
      name: name,
      imagePath: photoUrl,
      fontSize: fontSize,
      radius: radius,
    );
  }

  Color? chatColorName(List<Player> players) {
    var index = players.indexWhere((element) => element.userId == this.userId);
    if (index < 0) return Colors.primaries[0];

    if(index > 17)
      index = index - 17;

    return Colors.primaries[index];
  }

  Future<void> notifyPlayer(int eventId) async {
    await DatabaseServices.notifyUser(
      userId: userId,
      eventId: eventId,
    );
  }

  static PlayerRole getRoleFromId(int id) {
    PlayerRole result = PlayerRole.player;

    PlayerRole.values.forEach((role) {
      if (role.value == id) result = role;
    });

    return result;
  }

  static PlayerPosition? getPositionFromId({int? id}) {
    if (id == null) return null;

    PlayerPosition? result;

    PlayerPosition.values.forEach((position) {
      if (position.value == id) result = position;
    });

    return result;
  }

  @override
  int compareTo(other) {
    if (this.statusUpcomingMatch == other.statusUpcomingMatch)
      return ((this.stats?.goals ?? 0) + (this.stats?.assists ?? 0))
          .compareTo(((other.stats?.goals ?? 0) + (other.stats?.assists ?? 0)));

    if (this.statusUpcomingMatch == 1) return 1;

    if (this.statusUpcomingMatch == 0 && other.statusUpcomingMatch == 1)
      return -1;

    if (this.statusUpcomingMatch == 2 && other.statusUpcomingMatch == 1)
      return -1;

    if (this.statusUpcomingMatch == 0 && other.statusUpcomingMatch == 2)
      return 1;

    return 0;
  }
}

enum PlayerRole { coach, trainer, captain, player }

extension PlayerRoleExtension on PlayerRole {
  int get value {
    switch (this) {
      case PlayerRole.player:
        return 0;

      case PlayerRole.coach:
        return 1;

      case PlayerRole.trainer:
        return 2;

      case PlayerRole.captain:
        return 3;

      default:
        return 0;
    }
  }

  String get title {
    switch (this) {
      case PlayerRole.player:
        return AppLocalizations.of(Get.context!)!.player;

      case PlayerRole.coach:
        return AppLocalizations.of(Get.context!)!.coach;

      case PlayerRole.trainer:
        return AppLocalizations.of(Get.context!)!.trainer;

      case PlayerRole.captain:
        return AppLocalizations.of(Get.context!)!.captain;

      default:
        return AppLocalizations.of(Get.context!)!.player;
    }
  }

  Color? get color {
    switch (this) {
      case PlayerRole.player:
        return null;

      case PlayerRole.coach:
        return Color(0xfffa6400);

      case PlayerRole.trainer:
        return Color(0xff3cc8ff);

      case PlayerRole.captain:
        return Color(0xfff5a623);

      default:
        return null;
    }
  }

  Color? get radioBtnSelectColor {
    switch (this) {
      case PlayerRole.player:
        return null;

      case PlayerRole.coach:
        return Color(0xfffdedd3);

      case PlayerRole.trainer:
        return Color(0xffd6f3ff);

      case PlayerRole.captain:
        return Color(0xffffefe5);

      default:
        return null;
    }
  }

  Color? get radioBtnTextColor {
    switch (this) {
      case PlayerRole.player:
        return null;

      case PlayerRole.coach:
        return Color(0xfff7b649);

      case PlayerRole.trainer:
        return Color(0xff51ceff);

      case PlayerRole.captain:
        return Color(0xfffb8333);

      default:
        return null;
    }
  }

  String get radioBtnText {
    switch (this) {
      case PlayerRole.player:
        return '';

      case PlayerRole.coach:
        return 'CO';

      case PlayerRole.trainer:
        return 'T';

      case PlayerRole.captain:
        return 'C';

      default:
        return '';
    }
  }
}

enum PlayerPosition {
  keeper,
  centralDefender,
  leftBack,
  rightBack,
  defensiveMidfielder,
  leftMidfielder,
  rightMidfielder,
  attackingMidfielder,
  rightWingForward,
  leftWingForward,
  striker,
}

extension PlayerPositionExtension on PlayerPosition {
  String get title {
    switch (this) {
      case PlayerPosition.keeper:
        return AppLocalizations.of(Get.context!)!.keeper;
      case PlayerPosition.centralDefender:
        return AppLocalizations.of(Get.context!)!.centralDefender;
      case PlayerPosition.leftBack:
        return AppLocalizations.of(Get.context!)!.leftBack;
      case PlayerPosition.rightBack:
        return AppLocalizations.of(Get.context!)!.rightBack;
      case PlayerPosition.defensiveMidfielder:
        return AppLocalizations.of(Get.context!)!.defensiveMidfielder;
      case PlayerPosition.leftMidfielder:
        return AppLocalizations.of(Get.context!)!.leftMidfielder;
      case PlayerPosition.rightMidfielder:
        return AppLocalizations.of(Get.context!)!.rightMidfielder;
      case PlayerPosition.attackingMidfielder:
        return AppLocalizations.of(Get.context!)!.attackingMidfielder;
      case PlayerPosition.rightWingForward:
        return AppLocalizations.of(Get.context!)!.rightWingForward;
      case PlayerPosition.leftWingForward:
        return AppLocalizations.of(Get.context!)!.leftWingForward;
      case PlayerPosition.striker:
        return AppLocalizations.of(Get.context!)!.striker;
      default:
        return '';
    }
  }

  String get abbr {
    switch (this) {
      case PlayerPosition.keeper:
        return 'GK';
      case PlayerPosition.centralDefender:
        return 'CB';
      case PlayerPosition.leftBack:
        return 'LB';
      case PlayerPosition.rightBack:
        return 'RB';
      case PlayerPosition.defensiveMidfielder:
        return 'CDM';
      case PlayerPosition.leftMidfielder:
        return 'LM';
      case PlayerPosition.rightMidfielder:
        return 'RM';
      case PlayerPosition.attackingMidfielder:
        return 'AM';
      case PlayerPosition.rightWingForward:
        return 'RW';
      case PlayerPosition.leftWingForward:
        return 'LW';
      case PlayerPosition.striker:
        return 'ST';
      default:
        return '';
    }
  }

  int get value {
    switch (this) {
      case PlayerPosition.keeper:
        return 0;
      case PlayerPosition.centralDefender:
        return 1;
      case PlayerPosition.leftBack:
        return 2;
      case PlayerPosition.rightBack:
        return 3;
      case PlayerPosition.defensiveMidfielder:
        return 4;
      case PlayerPosition.leftMidfielder:
        return 5;
      case PlayerPosition.rightMidfielder:
        return 6;
      case PlayerPosition.attackingMidfielder:
        return 7;
      case PlayerPosition.rightWingForward:
        return 8;
      case PlayerPosition.leftWingForward:
        return 9;
      case PlayerPosition.striker:
        return 10;
      default:
        return 0;
    }
  }
}
