class Skills {
  int? id;
  int? pace;
  int? shooting;
  int? passing;
  int? dribbling;
  int? defending;
  int? physical;

  Skills({
    this.id,
    this.pace,
    this.shooting,
    this.passing,
    this.defending,
    this.dribbling,
    this.physical,
  });

  Map<String, dynamic> get toMap {
    return {
      'id': id,
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'defending': defending,
      'dribbling': dribbling,
      'physical': physical,
    };
  }

  factory Skills.fromMap({Map<String, dynamic>? map}) {
    if (map == null) return Skills();

    return Skills(
      id: map['id'],
      pace: map['pace'],
      shooting: map['shooting'],
      passing: map['passing'],
      defending: map['defending'],
      dribbling: map['dribbling'],
      physical: map['physical'],
    );
  }
}
