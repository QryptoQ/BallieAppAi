import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:yescoach/widgets/user_avatar.dart';

enum Gender { male, female }

extension GenderExtension on Gender {
  String get title {
    switch (this) {
      case Gender.male:
        return AppLocalizations.of(Get.context!)!.male;
      case Gender.female:
        return AppLocalizations.of(Get.context!)!.female;
      default:
        return '';
    }
  }
}

class YaUser {
  int id;
  String? name;
  String? lastname;
  String? email;
  String? facebookId;
  String? googleId;
  String? appleId;
  DateTime? birthDate;
  Gender? gender;
  String? photoUrl;
  String? verifyCode;

  YaUser(
      {required this.id,
      this.name,
      this.lastname,
      this.email,
      this.facebookId,
      this.googleId,
      this.appleId,
      this.birthDate,
      this.gender,
      this.photoUrl,
      this.verifyCode});

  factory YaUser.fromMap(Map<String, dynamic> map) {
    print('user map: $map');

    return YaUser(
      id: map['id'],
      name: map['name'],
      lastname: map['last_name'],
      email: map['email'],
      facebookId: map['facebook_id'],
      googleId: map['google_id'],
      appleId: map['apple_id'],
      verifyCode: map['verify_code'],
      birthDate: map['birth_date'] == null
          ? null
          : _stringToDatetime(map['birth_date']),
      gender: map['gender'] == 0
          ? Gender.male
          : map['gender'] == 1
              ? Gender.female
              : null,
      photoUrl: map['photo_url'],
    );
  }

  void fromOldUser(YaUser yaUser) {
    this.name = yaUser.name ?? this.name;
    this.lastname = yaUser.lastname ?? this.lastname;
    this.email = yaUser.email ?? this.email;
    this.facebookId = yaUser.facebookId ?? this.facebookId;
    this.googleId = yaUser.googleId ?? this.googleId;
    this.appleId = yaUser.appleId ?? this.appleId;
    this.birthDate = yaUser.birthDate ?? this.birthDate;
    this.gender = yaUser.gender ?? this.gender;
    this.photoUrl = yaUser.photoUrl ?? this.photoUrl;
  }

  Map<String, dynamic> get toMap {
    var map = {
      'name': this.name,
      'last_name': this.lastname,
      'birth_date':
          this.birthDate == null ? null : _dateTimeToString(this.birthDate!),
      'gender': this.gender?.index.toString() ?? '0',
      // 'photo_url': this.photoUrl,
    };

    map.removeWhere((key, value) => value == null);

    return map;
  }

  static DateTime _stringToDatetime(String str) {
    return DateTime(
      int.parse(str.substring(0, 4)),
      int.parse(str.substring(5, 7)),
      int.parse(str.substring(8, 10)),
    );
  }

  static String _dateTimeToString(DateTime dateTime) {
    var str = DateFormat.yMd('fr-CA').format(dateTime);
    return str;
  }

  Widget userAvatar({double radius = 30.0, double fontSize = 45}) {
    try {
      return UserAvatar(
        id: this.id,
        name: this.name!,
        imagePath: photoUrl,
        radius: radius,
        fontSize: fontSize,
      );
    } catch (e) {
      print('userAvatar error: $e');

      return Container(
        child: CircleAvatar(
          backgroundImage: AssetImage(
            'assets/images/icon_new.png',
          ),
          radius: 24,
          child: Container(),
        ),
      );
    }
  }
}
