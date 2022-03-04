import 'dart:io';

import 'package:birdseye/scouting.dart';
import 'package:csv/csv.dart' as csv;
import 'package:path/path.dart' as path;

class TeamDocument {
  String team;
  List<ScoutingDocument> docs = [];

  TeamDocument({required this.team, required this.docs}) {}
}

class Database {
  String databaseName = "birdseye";
  Directory? rootDir;
  List<TeamDocument> teams = [];

  Database({String? dir}) {
    if (dir != null) {
      this.rootDir = dir.endsWith(databaseName)
          ? Directory(dir)
          : Directory(path.join(dir, this.databaseName));
      if (!rootDir!.existsSync()) {
        rootDir!.createSync(recursive: true);
      }
    }
  }

  Database.from(Database old) {
    this.databaseName = old.databaseName;
    this.rootDir = old.rootDir;
    this.teams = old.teams;
  }

  searchRoot() {
    final List<FileSystemEntity> filePaths = rootDir!.listSync();
    for (FileSystemEntity filePath in filePaths) {
      if (filePath.path.endsWith(".csv")) {
        File file = File(filePath.path);
        String data = file.readAsStringSync();
        final List<List<dynamic>> CSVData =
            csv.CsvToListConverter().convert(data).skip(1).toList();
        for (List<dynamic> CSVDoc in CSVData) {
          ScoutingDocument doc = ScoutingDocument.fromCSV(CSVDoc);
          Iterable<TeamDocument> teamExists =
              teams.where((el) => el.team == doc.team);
          if (teamExists.isEmpty) {
            TeamDocument newTeam = TeamDocument(team: doc.team, docs: [doc]);
            teams.add(newTeam);
            return;
          }
          //If team exists, locate it;
          TeamDocument team = teamExists.first;
          int location = teams.indexOf(team);
          //Does team have a document of this match?
          Iterable<ScoutingDocument> docExists =
              team.docs.where((el) => el.match == doc.match);

          //If doc doesn't exist, create it.
          if (docExists.isEmpty) {
            team.docs.add(doc);
          } else {
            //If it does, overwrite it.
            int docLoc = team.docs.indexOf(docExists.first);
            team.docs[docLoc] = doc;
          }
          //Over write team data
          teams[location] = team;
        }
      }
    }
  }

  saveToDisk() {
    if (this.rootDir != null) {
      String savePath = path.join(this.rootDir!.path, 'db.csv');
      File saveFile = File(savePath);
      List<List<dynamic>> dbCSV = teams.expand((team) {
        return team.docs.map((doc) {
          return doc.toCSV();
        }).toList();
      }).toList();
      String saveable = csv.ListToCsvConverter().convert([
        [
          "Team",
          "Match",
          "Auto:Taxied",
          "Auto:Distance",
          "Auto:Lower:Attempted",
          "Auto:Lower:Scored",
          "Auto:Upper:Attempted",
          "Auto:Upper:Scored",
          "Teleop:Distance",
          "Teleop:Lower:Attempted",
          "Teleop:Lower:Scored",
          "Teleop:Upper:Attempted",
          "Teleop:Upper:Scored",
          "Teleop:Hang:Selection",
          "Teleop:Hang:Completion",
          "Teleop:Hang:Time",
          "Broke",
          "Disconnected",
          "Comments"
        ],
        ...dbCSV
      ]);
      saveFile.writeAsString(saveable);
    }
  }
}
