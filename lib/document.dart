enum ShootingDistance { fender, hanger, wallRed, wallBlue, varies }
const ShootingDistanceLabels = {
  ShootingDistance.fender: "Fender",
  ShootingDistance.hanger: "Hanger",
  ShootingDistance.wallRed: "Wall (Red)",
  ShootingDistance.wallBlue: "Wall (Blue)",
  ShootingDistance.varies: "Varies"
};
enum HangingChoice { low, mid, high, traversal }
const HangingChoiceLabels = {
  HangingChoice.low: "Low",
  HangingChoice.mid: "Mid",
  HangingChoice.high: "High",
  HangingChoice.traversal: "Traversal"
};
enum HangingCompletion { noAttempt, attempted, accomplished }
const HangingCompletionLabels = {
  HangingCompletion.noAttempt: "No Attempt",
  HangingCompletion.attempted: "Attempted",
  HangingCompletion.accomplished: "Accomplished"
};
enum CargoGoal { low, high }

class CargoShot {
  CargoGoal goal;
  int attempted;
  int scored;

  CargoShot({
    required this.goal,
    required this.attempted,
    required this.scored,
  });

  @override
  String toString() {
    return '$scored/$attempted';
  }
}

class AutoSection {
  bool taxied;
  CargoShot cargoLower;
  CargoShot cargoUpper;
  ShootingDistance shootingDistance;

  AutoSection(
      {required this.taxied,
      required this.cargoLower,
      required this.cargoUpper,
      required this.shootingDistance});

  @override
  String toString() {
    return 'Auto{taxied: $taxied, cargoLower: $cargoLower, cargoUpper: $cargoUpper, shootingDistance: $shootingDistance}';
  }
}

class TeleopSection {
  ShootingDistance shootingDistance;
  CargoShot cargoLower;
  CargoShot cargoUpper;
  HangingChoice hangingChoice;
  HangingCompletion hangingCompletion;
  Stopwatch hangTime;

  TeleopSection(
      {required this.shootingDistance,
      required this.cargoLower,
      required this.cargoUpper,
      required this.hangingChoice,
      required this.hangingCompletion,
      required this.hangTime});
}

class Conditions {
  bool broke;
  bool disconnect;

  Conditions({required this.broke, required this.disconnect});
}

class ScoutingDocument {
  int id;
  int team;
  int match;
  AutoSection auto;
  TeleopSection teleop;
  Conditions conditions;
  String comments;

  ScoutingDocument(
      {required this.id,
      required this.team,
      required this.match,
      required this.auto,
      required this.teleop,
      required this.conditions,
      required this.comments});

  static ScoutingDocument from(ScoutingDocument old) {
    return new ScoutingDocument(
        id: old.id,
        team: old.team,
        match: old.match,
        auto: old.auto,
        teleop: old.teleop,
        conditions: old.conditions,
        comments: old.comments);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'team': this.team,
      'match': this.match,
      'autoTaxied': this.auto.taxied ? 1 : 0,
      'autoCargoLowerAttempts': this.auto.cargoLower.attempted,
      'autoCargoLowerScored': this.auto.cargoLower.scored,
      'autoCargoUpperAttempts': this.auto.cargoUpper.attempted,
      'autoCargoUpperScored': this.auto.cargoUpper.scored,
      'autoShootingDistance': this.auto.shootingDistance.index,
      'teleShootingDistance': this.teleop.shootingDistance.index,
      'teleCargoLowerAttempts': this.teleop.cargoLower.attempted,
      'teleCargoLowerScored': this.teleop.cargoLower.scored,
      'teleCargoUpperAttempts': this.teleop.cargoUpper.attempted,
      'teleCargoUpperScored': this.teleop.cargoUpper.scored,
      'teleHangingChoice': this.teleop.hangingChoice.index,
      'teleHangingCompletion': this.teleop.hangingCompletion.index,
      'teleHangingTime': this.teleop.hangTime.elapsedMilliseconds,
      'broke': this.conditions.broke ? 1 : 0,
      'disconnect': this.conditions.disconnect ? 1 : 0,
      'comments': this.comments
    };
  }

  @override
  String toString() {
    return 'Document{id: $id, team: $team, match: $match, auto: $auto, teleop: $teleop, conditions: $conditions, comments: $comments}';
  }
}
