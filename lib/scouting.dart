import 'package:birdseye/enums.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CargoScoring {
  int attempted;
  int scored;

  CargoScoring({this.attempted = 0, this.scored = 0}) {}

  @override
  String toString() {
    return '$scored/$attempted';
  }
}

class HangScoring {
  HangingSelection selection;
  HangingCompletion completion;
  int time;
  Stopwatch? stopwatch;

  HangScoring(
      {this.selection = HangingSelection.low,
      this.completion = HangingCompletion.noAttempt,
      this.time = 0,
      this.stopwatch}) {}

  String timeString() {
    return '${time / 1000}s';
  }

  @override
  String toString() {
    return 'Hang{ selection: $selection, completion: $completion, time: ${timeString()}}';
  }
}

class AutonomousSection {
  bool taxied;
  CargoScoring upper = CargoScoring();
  CargoScoring lower = CargoScoring();
  ShootingDistance distance;

  AutonomousSection(
      {this.taxied = false,
      this.distance = ShootingDistance.varies,
      CargoScoring? upper,
      CargoScoring? lower}) {
    if (upper != null) this.upper = upper;
    if (lower != null) this.lower = lower;
  }

  @override
  String toString() {
    return 'Auto{ taxied: $taxied, upper: $upper, lower: $lower, distance: $distance}';
  }
}

class TeleopSection {
  CargoScoring upper = CargoScoring();
  CargoScoring lower = CargoScoring();
  ShootingDistance distance;
  HangScoring hang = HangScoring();

  TeleopSection(
      {CargoScoring? upper,
      CargoScoring? lower,
      this.distance = ShootingDistance.varies,
      HangScoring? hang}) {
    if (upper != null) this.upper = upper;
    if (lower != null) this.lower = lower;
    if (hang != null) this.hang = hang;
  }

  @override
  String toString() {
    return 'Teleop{ upper: $upper, lower: $lower, distance: $distance, hang: $hang}';
  }
}

class ScoutingDocument {
  String team;
  String match;
  AutonomousSection auto = AutonomousSection();
  TeleopSection teleop = TeleopSection();
  bool broke;
  bool disconnected;
  String comments;

  ScoutingDocument(
      {this.team = "",
      this.match = "",
      AutonomousSection? auto,
      TeleopSection? teleop,
      this.broke = false,
      this.disconnected = false,
      this.comments = ""}) {
    if (auto != null) this.auto = auto;
    if (teleop != null) this.teleop = teleop;
  }

  static from(ScoutingDocument old) {
    return ScoutingDocument(
        team: old.team,
        match: old.match,
        auto: old.auto,
        teleop: old.teleop,
        broke: old.broke,
        disconnected: old.disconnected,
        comments: old.comments);
  }

  static fromCSV(List<dynamic> data) {
    return ScoutingDocument(
        team: data[0].toString(),
        match: data[1].toString(),
        auto: AutonomousSection(
            taxied: data[2] == 0 ? false : true,
            distance: ShootingDistance.values[data[3]],
            lower: CargoScoring(attempted: data[4], scored: data[5]),
            upper: CargoScoring(attempted: data[6], scored: data[7])),
        teleop: TeleopSection(
            distance: ShootingDistance.values[data[8]],
            lower: CargoScoring(attempted: data[9], scored: data[10]),
            upper: CargoScoring(attempted: data[11], scored: data[12]),
            hang: HangScoring(
                selection: HangingSelection.values[data[13]],
                completion: HangingCompletion.values[data[14]],
                time: data[15])),
        broke: data[16] == 0 ? false : true,
        disconnected: data[17] == 0 ? false : true,
        comments: data[18]);
  }

  List<dynamic> toCSV() {
    return [
      this.team,
      this.match,
      this.auto.taxied ? 1 : 0,
      this.auto.distance.index,
      this.auto.lower.attempted,
      this.auto.lower.scored,
      this.auto.upper.attempted,
      this.auto.upper.scored,
      this.teleop.distance.index,
      this.teleop.lower.attempted,
      this.teleop.lower.scored,
      this.teleop.upper.attempted,
      this.teleop.upper.scored,
      this.teleop.hang.selection.index,
      this.teleop.hang.completion.index,
      this.teleop.hang.time,
      this.broke ? 1 : 0,
      this.disconnected ? 1 : 0,
      this.comments.length > 0 ? this.comments : ""
    ];
  }

  @override
  String toString() {
    return 'ScoutingDocument{ team: $team, match: $match, auto: $auto, teleop: $teleop, broke: $broke, disconnected: $disconnected }';
  }
}
