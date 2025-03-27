import 'package:flutter/material.dart';
import 'package:yescoach/widgets/events/team_avatar.dart';

class Team {
  String? imagePath;
  int? teamId;
  String teamName;
  String? teamCode;
  String? gender;
  String? category;
  String? poolId;
  YaUserType? userType;
  bool? activeTeam = false;
  int? played;
  int? wins;
  int? draws;
  int? losses;
  int? points;
  int? teamRank;
  bool? updated;

  Team({
    this.imagePath,
    this.teamId,
    required this.teamName,
    this.gender,
    this.teamCode,
    this.category,
    this.userType,
    this.played,
    this.activeTeam,
    this.draws,
    this.losses,
    this.points,
    this.wins,
    this.teamRank,
    this.updated
  });

  // Based on API: /v1/event/upcoming:
  factory Team.fromMapUpcomingEvents({
    required String teamName,
    String? logoUrl,
    String? teamCode,
    int? teamId,
  }) {
    return Team(
      teamId: teamId,
      teamCode: teamCode,
      imagePath: logoUrl,
      teamName: teamName,
    );
  }

  Widget logo({double radius = 32.0}) {
    return TeamAvatar(
      logoPath: imagePath,
      radius: radius,
    );
  }
}

enum YaUserType { coach, player }
