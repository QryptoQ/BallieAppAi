import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:yescoach/models/stats.dart';
import 'package:yescoach/models/substitute.dart';
import 'package:yescoach/models/ya_event.dart';
import 'package:yescoach/services/database.dart';
import 'team.dart';
import 'player.dart';

class YaMatch extends YaEvent {
  int? id;
  final YaEventType eventType = YaEventType.match;
  YaEventUserStatus userStatus;
  String? matchDetail;
  String? gatheringTime;
  String? roomNumber;
  String? playingField;
  String? comment;
  Team? homeTeam;
  Team? awayTeam;
  String? date;
  String? startTime;
  DateTime? startDateTime;
  String? endTime;
  String? location;
  String? city;
  String? referee;
  String? assistantReferee;
  String? costPerPerson;
  String? totalCost;
  int presentCount;
  List<Player>? presentPlayers;
  List<Player>? absentPlayers;
  List<Player>? nonRespondentPlayers;
  String? payment;
  int? awayTeamScore;
  int? homeTeamScore;
  bool? isHome;
  List<Player>? scorers;
  List<Player>? assists;
  List<Substitute>? subs;

  YaMatch({
    this.id,
    this.payment,
    this.matchDetail,
    this.gatheringTime,
    this.comment,
    this.playingField,
    this.roomNumber,
    this.userStatus = YaEventUserStatus.idle,
    this.homeTeam,
    this.awayTeam,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.city,
    this.referee,
    this.assistantReferee,
    this.startDateTime,
    this.costPerPerson,
    this.totalCost,
    this.presentCount = 0,
    this.presentPlayers = const <Player>[],
    this.absentPlayers = const <Player>[],
    this.nonRespondentPlayers = const <Player>[],
    this.awayTeamScore,
    this.homeTeamScore,
    this.scorers,
    this.assists,
    this.subs,
    this.isHome,
  });

  factory YaMatch.fromMap(Map<String, dynamic> map) {
    DateTime _start = DateTime.parse(map['start_time']);
    DateTime _end = DateTime.parse(map['end_time']);
    DateTime? _gathering_time;
    if(map['gathering_time'] != null)
       _gathering_time = DateTime.parse(map['gathering_time']);

    var localeName = AppLocalizations.of(Get.context!)!.localeName;

    return YaMatch(
      id: map['id'],
      userStatus: YaEventStatusExtension.getStatusFromValue(map['status']),
      homeTeam: map['home_away'] == 0
          ? Team.fromMapUpcomingEvents(
              teamName: map['enemy_team_name'] ??
                  AppLocalizations.of(Get.context!)!.enemyTeam,
              logoUrl: map['enemy_team_logo_url'],
            )
          : Team.fromMapUpcomingEvents(
              teamName: map['team_full_name'] ??
                  AppLocalizations.of(Get.context!)!.teamName,
              logoUrl: map['logo_url'],
            ),
      awayTeam: map['home_away'] == 0
          ? Team.fromMapUpcomingEvents(
              teamName: map['team_full_name'] ?? '',
              logoUrl: map['logo_url'],
            )
          : Team.fromMapUpcomingEvents(
        teamName: map['enemy_team_name'] ??
            AppLocalizations.of(Get.context!)!.enemyTeam,
              logoUrl: map['enemy_team_logo_url'],
            ),
        startDateTime: _start,
        date: DateFormat('E dd-MM-yyyy', localeName).format(_start),
      startTime: DateFormat('HH:mm').format(_start),
      endTime: DateFormat('HH:mm').format(_end),
      gatheringTime: _gathering_time != null ? DateFormat('HH:mm').format(_gathering_time) : null,
      location: map['address'],
      city: map['city'],
      referee: map['referee'],
      assistantReferee: map['assistant_referee'],
      payment: map['payment'],
      playingField: map['field'],
      costPerPerson: map['cost_per_person'],
      totalCost: map['total_cost'],
      presentCount: map['amount_present'],
      comment: map['note'],
      roomNumber: map['room'],
      isHome: map['home_away'] == 1
    );
  }

  int? goalsByPlayer(int userId) {
    if (this.scorers?.any((player) => player.userId == userId) ?? false) {
      return this
          .scorers
          ?.firstWhere((player) => player.userId == userId)
          .stats
          ?.goals;
    }

    return null;
  }

  int? assistsByPlayer(int userId) {
    if (this.assists?.any((player) => player.userId == userId) ?? false) {
      return this
          .assists
          ?.firstWhere((player) => player.userId == userId)
          .stats
          ?.assists;
    }

    return null;
  }

  String get goalScorersText {
    if ((scorers?.length ?? 0) == 0) return '';

    var result = '';
    scorers!.forEach((player) {
      if ((player.stats?.goals ?? 0) > 0) {
        if (result != '') result += ' - ';
        result += '${player.name} (${player.stats?.goals ?? '-'})';
      }
    });

    return result;
  }

  // String get assistersText {
  //   if ((assists?.length ?? 0) == 0) return '';

  //   var result = '';

  //   assists!.forEach((player) {
  //     result += '${player.name} (${player.stats?.assists ?? '-'})';
  //   });

  //   return result;
  // }

  void updatePlayerGoal(Player player, int goal) {
    print('update ${player.userId} ${player.name} goal => $goal');
    if (this.scorers?.any((p) => p.userId == player.userId) ?? false) {
      this.scorers!.firstWhere((p) => p.userId == player.userId).stats!.goals =
          goal;
    } else {
      if (player.stats == null) player.stats = Stats();
      player.stats!.goals = goal;

      if (this.scorers == null) this.scorers = <Player>[];

      this.scorers!.add(player);
    }
  }

  void updatePlayerAssist(Player player, int assist) {
    print('update ${player.userId} ${player.name} assist => $assist');

    if (this.assists?.any((p) => p.userId == player.userId) ?? false) {
      this
          .assists!
          .firstWhere((p) => p.userId == player.userId)
          .stats!
          .assists = assist;
    } else {
      if (player.stats == null) player.stats = Stats();
      player.stats!.assists = assist;

      if (this.assists == null) this.assists = <Player>[];

      this.scorers!.add(player);
    }
  }

  Future<void> setSubsData() async {
    if (this.id != null) {
      subs = await DatabaseServices.getSubs(this.id!);
    }
  }

  Substitute? getPlayerSub(int playerId) {
    if (subs?.any((sub) => sub.player.userId == playerId) ?? false) {
      return subs!.firstWhere((sub) => sub.player.userId == playerId);
    }
  }

  @override
  Future<void> setPlayersData() async {
    if (id != null) {
      var map = await DatabaseServices.getPlayersDataForEvent(id!);

      // AppLocalizations.of(Get.context!)!.presentPlayers:
      var _presentPlayers = <Player>[];
      ((map['present'] ?? []) as List<dynamic>).forEach((p) {
        _presentPlayers.add(
          Player(
            userId: p['user_id'],
            name: p['name'],
            photoUrl: p['photo_url'],
            eventStatusUpdatedAt: DateTime.parse(p['updated_at'])
          ),
        );
      });

      // Absent players:
      var _absentPlayers = <Player>[];
      ((map['absent'] ?? []) as List<dynamic>).forEach((p) {
        _absentPlayers.add(
          Player(
            userId: p['user_id'],
            name: p['name'],
            photoUrl: p['photo_url'],
              absentReason: p['absent_reason'],
              eventStatusUpdatedAt: DateTime.parse(p['updated_at'])
          ),
        );
      });

      // Non-respondent players:
      var _nonResPlayers = <Player>[];
      ((map['idle'] ?? []) as List<dynamic>).forEach((p) {
        _nonResPlayers.add(
          Player(
            userId: p['user_id'],
            name: p['name'],
            photoUrl: p['photo_url'],
            eventStatusUpdatedAt: DateTime.parse(p['updated_at'])
          ),
        );
      });

      this.presentPlayers = _presentPlayers;
      this.absentPlayers = _absentPlayers;
      this.nonRespondentPlayers = _nonResPlayers;
    }
  }

  @override
  void acceptEvent(
    int userId, {
    YaEventUserStatus? oldStatus,
    bool updatePlayers = false,
    bool updateCurrentUserStatus = true,
  }) {
    if (oldStatus == null) oldStatus = userStatus;
    var newStatus = oldStatus;

    print('accept event userId: $userId');

    if (id != null) {
      print('present: ${this.presentPlayers?.length ?? "null"}');
      print('nr: ${this.nonRespondentPlayers?.length ?? "null"}');

      if (oldStatus == YaEventUserStatus.present) {
        if (updatePlayers) {
          // Present => Idle:
          var _player = presentPlayers!.firstWhere((p) => p.userId == userId);
          presentPlayers!.remove(_player);
          (nonRespondentPlayers ?? <Player>[]).add(_player);
        }

        this.presentCount--;

        newStatus = YaEventUserStatus.idle;
      } else if (oldStatus == YaEventUserStatus.absent) {
        if (updatePlayers) {
          // Absent => Present:
          var _player = absentPlayers!.firstWhere((p) => p.userId == userId);
          absentPlayers!.remove(_player);
          (presentPlayers ?? <Player>[]).add(_player);
        }

        this.presentCount++;

        newStatus = YaEventUserStatus.present;
      } else {
        if (updatePlayers) {
          // Idle => Present:
          var _player =
              nonRespondentPlayers!.firstWhere((p) => p.userId == userId);
          nonRespondentPlayers!.remove(_player);
          (presentPlayers ?? <Player>[]).add(_player);
        }

        this.presentCount++;

        newStatus = YaEventUserStatus.present;
      }

      if (updateCurrentUserStatus) {
        userStatus = newStatus;

        DatabaseServices.changeEventStatus(
          id!,
          newStatus.value,
        ).then((_) {
          print('changeEventStatus finished => $userStatus');
        }).onError((error, _) {
          print('changeEventStatus error: $error');
        });
      } else {
        DatabaseServices.changeEventStatus(
          id!,
          newStatus.value,
          userId: userId,
        ).then((_) {
          print('changeEventStatus finished => $userStatus');
        }).onError((error, _) {
          print('changeEventStatus error: $error');
        });
      }
    }
  }

  @override
  void rejectEvent(
    int userId, {
    YaEventUserStatus? oldStatus,
    bool updatePlayers = false,
    bool updateCurrentUserStatus = true
  }) {
    if (oldStatus == null) oldStatus = userStatus;
    var newStatus = oldStatus;

    print('reject event userId: $userId');

    if (id != null) {
      if (oldStatus == YaEventUserStatus.present) {
        print('Present => Absent');
        if (updatePlayers) {
          // Present => Absent:
          var _player = presentPlayers!.firstWhere((p) => p.userId == userId);
          presentPlayers!.remove(_player);
          (absentPlayers ?? <Player>[]).add(_player);
        }

        this.presentCount--;
        newStatus = YaEventUserStatus.absent;
      } else if (oldStatus == YaEventUserStatus.absent) {
        print('Absent => Idle');
        if (updatePlayers) {
          // Absent => Idle:
          var _player = absentPlayers!.firstWhere((p) => p.userId == userId);
          absentPlayers!.remove(_player);
          (nonRespondentPlayers ?? <Player>[]).add(_player);
        }

        newStatus = YaEventUserStatus.idle;
      } else {
        print('Idle => Absent');
        if (updatePlayers) {
          // Idle => Absent:
          var _player =
              nonRespondentPlayers!.firstWhere((p) => p.userId == userId);
          nonRespondentPlayers!.remove(_player);
          (absentPlayers ?? <Player>[]).add(_player);
        }

        newStatus = YaEventUserStatus.absent;
      }

      if (updateCurrentUserStatus) {
        userStatus = newStatus;

        DatabaseServices.changeEventStatus(
          id!,
          newStatus.value,
        ).then((_) {
          print('changeEventStatus finished => $userStatus');
        }).onError((error, _) {
          print('changeEventStatus error: $error');
        });
      } else {
        DatabaseServices.changeEventStatus(
          id!,
          newStatus.value,
          userId: userId,
        ).then((_) {
          print('changeEventStatus finished => $userStatus');
        }).onError((error, _) {
          print('changeEventStatus error: $error');
        });
      }
    }
  }
}
