import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/database.dart';
import './ya_event.dart';
import './player.dart';

enum YaTrainingReccurance { weekly, once }

extension YaTrainingReccuranceExtension on YaTrainingReccurance {
  String get title {
    switch (this) {
      case YaTrainingReccurance.weekly:
        return AppLocalizations.of(Get.context!)!.weekly;

      case YaTrainingReccurance.once:
        return AppLocalizations.of(Get.context!)!.oneOff;

      default:
        return '';
    }
  }
}

class YaTraining extends YaEvent {
  int? id;
  final YaEventType eventType = YaEventType.training;
  YaEventUserStatus userStatus;
  String? title;

  // String? trainingDetail;
  YaTrainingReccurance trainingReccurance;
  String? logoPath;
  String? date;
  DateTime? startDateTime;
  String? endDate;
  String? gatheringTime;
  String? startTime;
  String? endTime;
  String? location;
  String? city;
  int? roomNumber;
  String? playingField;
  int? numberOfOccurring;
  int presentCount;
  String? comment;
  List<Player>? presentPlayers;
  List<Player>? absentPlayers;
  List<Player>? nonRespondentPlayers;

  YaTraining({
    this.id,
    this.userStatus = YaEventUserStatus.absent,
    this.title,
    // this.trainingDetail,
    this.trainingReccurance = YaTrainingReccurance.weekly,
    this.logoPath,
    this.date,
    this.startDateTime,
    this.gatheringTime,
    this.startTime,
    this.endTime,
    this.location,
    this.city,
    this.roomNumber,
    this.playingField,
    this.comment,
    this.numberOfOccurring,
    this.presentCount = 0,
    this.presentPlayers = const <Player>[],
    this.absentPlayers = const <Player>[],
    this.nonRespondentPlayers = const <Player>[],
  });

  Map<String, dynamic> get toMap {
    return {
      'id': id,
      'userStatus': userStatus,
      'title': title,
      // 'trainingDetail': trainingDetail,
      'weekly': trainingReccurance == YaTrainingReccurance.weekly,
      'logoPath': logoPath,
      'date': date,
      'gatheringTime': gatheringTime,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'roomNumber': roomNumber,
      'playingField': playingField,
      'comment': comment,
      'numberOfOccurring': numberOfOccurring,
      'presentCount': presentCount,
      'presentPlayers': presentPlayers,
      'absentPlayers': absentPlayers,
      'nonRespondentPlayers': nonRespondentPlayers,
    };
  }

  factory YaTraining.fromMap(Map<String, dynamic> map) {
    DateTime _start = DateTime.parse(map['start_time']);
    DateTime _end = DateTime.parse(map['end_time']);
    DateTime? _gathering_time;
    if (map['gathering_time'] != null)
      _gathering_time = DateTime.parse(map['gathering_time']);

    var localeName = AppLocalizations.of(Get.context!)!.localeName;

    return YaTraining(
      id: map['id'],
      userStatus: YaEventStatusExtension.getStatusFromValue(map['status']),
      title: 'Training',
      logoPath: map['logo_url'],
      date: DateFormat('E dd-MM-yyyy', localeName).format(_start),
      startDateTime: _start,
      startTime: DateFormat('HH:mm').format(_start),
      endTime: DateFormat('HH:mm').format(_end),
      location: map['address'],
      city: map['city'],
      numberOfOccurring: 0,
      presentCount: map['amount_present'],
      gatheringTime: _gathering_time != null
          ? DateFormat('HH:mm').format(_gathering_time)
          : null,
      comment: map['note'],
      roomNumber: map['room'] != null ? int.parse(map['room']) : null,
      playingField: map['field'],
    );
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
  void rejectEvent(int userId, {YaEventUserStatus? oldStatus, bool updatePlayers = false, bool updateCurrentUserStatus = true}) {
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
          var _player = nonRespondentPlayers!.firstWhere((p) => p.userId == userId);
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
