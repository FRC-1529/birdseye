import 'dart:io';

import 'package:csv/csv.dart' as csv;
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'document.dart';

final dbProvider = StateNotifierProvider<DocumentDatabase, Database>((ref) {
  return DocumentDatabase();
});

class DocumentDatabase extends StateNotifier<Database> {
  DocumentDatabase() : super(Database());

  void setSavingPath(String path) {
    Database newDB = Database.from(state);
    newDB.savingPath = path;
    newDB.loadDatabase();
    state = newDB;
  }
}

class Database {
  String databaseName = "birdseye";

  List<ScoutingDocument>? documents;
  String? savingPath;

  Database(
      {this.databaseName = "birdseye", this.documents, this.savingPath = ""}) {}

  static Database from(Database old) {
    return new Database(
        databaseName: old.databaseName,
        documents: old.documents,
        savingPath: old.savingPath);
  }

  void loadDatabase() {
    final sp = this.savingPath;
    if (sp != null) {
      final dir = sp.endsWith(this.databaseName)
          ? Directory(sp)
          : new Directory(path.join(sp, this.databaseName));

      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final files = dir.listSync();
      for (FileSystemEntity file in files) {
        if (file.path.endsWith(".csv")) {
          File f = File(file.path);
          String data = f.readAsStringSync();
        }
      }
    }
  }
}

final currentDocumentProvider =
    StateNotifierProvider<Document, ScoutingDocument>((ref) {
  return Document();
});

class Document extends StateNotifier<ScoutingDocument> {
  Document()
      : super(ScoutingDocument(
            id: 1,
            team: 0,
            match: 0,
            auto: AutoSection(
                taxied: false,
                cargoLower:
                    CargoShot(goal: CargoGoal.low, attempted: 0, scored: 0),
                cargoUpper:
                    CargoShot(goal: CargoGoal.high, attempted: 0, scored: 0),
                shootingDistance: ShootingDistance.varies),
            teleop: TeleopSection(
                shootingDistance: ShootingDistance.varies,
                cargoLower:
                    CargoShot(goal: CargoGoal.low, attempted: 0, scored: 0),
                cargoUpper:
                    CargoShot(goal: CargoGoal.high, attempted: 0, scored: 0),
                hangingChoice: HangingChoice.low,
                hangingCompletion: HangingCompletion.noAttempt,
                hangTime: Stopwatch()),
            conditions: Conditions(broke: false, disconnect: false),
            comments: ""));

  void setTaxied(bool value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.taxied = value;
    state = newDoc;
  }

  void setAutoShootingDistance(ShootingDistance value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.shootingDistance = value;
    state = newDoc;
  }

  void addAutoScoredLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.cargoLower.attempted++;
    newDoc.auto.cargoLower.scored++;
    state = newDoc;
  }

  void addAutoAttemptedLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.cargoLower.attempted++;
    state = newDoc;
  }

  void removeAutoAttemptLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    if (newDoc.auto.cargoLower.attempted > 0) {
      newDoc.auto.cargoLower.attempted--;
    }
    if (newDoc.auto.cargoLower.scored > 0) {
      newDoc.auto.cargoLower.scored--;
    }
    state = newDoc;
  }

  void addAutoScoredUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.cargoUpper.attempted++;
    newDoc.auto.cargoUpper.scored++;
    state = newDoc;
  }

  void addAutoAttemptedUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.auto.cargoUpper.attempted++;
    state = newDoc;
  }

  void removeAutoAttemptUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    if (newDoc.auto.cargoUpper.attempted > 0) {
      newDoc.auto.cargoUpper.attempted--;
    }
    if (newDoc.auto.cargoUpper.scored > 0) {
      newDoc.auto.cargoUpper.scored--;
    }
    state = newDoc;
  }

  //=======================

  void setTeleopShootingDistance(ShootingDistance value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.shootingDistance = value;
    state = newDoc;
  }

  void addTeleopScoredLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.cargoLower.attempted++;
    newDoc.teleop.cargoLower.scored++;
    state = newDoc;
  }

  void addTeleopAttemptedLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.cargoLower.attempted++;
    state = newDoc;
  }

  void removeTeleopAttemptLower() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    if (newDoc.teleop.cargoLower.attempted > 0) {
      newDoc.teleop.cargoLower.attempted--;
    }
    if (newDoc.teleop.cargoLower.scored > 0) {
      newDoc.teleop.cargoLower.scored--;
    }
    state = newDoc;
  }

  void addTeleopScoredUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.cargoUpper.attempted++;
    newDoc.teleop.cargoUpper.scored++;
    state = newDoc;
  }

  void addTeleopAttemptedUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.cargoUpper.attempted++;
    state = newDoc;
  }

  void removeTeleopAttemptUpper() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    if (newDoc.teleop.cargoUpper.attempted > 0) {
      newDoc.teleop.cargoUpper.attempted--;
    }
    if (newDoc.teleop.cargoUpper.scored > 0) {
      newDoc.teleop.cargoUpper.scored--;
    }
    state = newDoc;
  }

  void setHangChoice(HangingChoice value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.hangingChoice = value;
    state = newDoc;
  }

  void setHangCompletion(HangingCompletion value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.hangingCompletion = value;
    state = newDoc;
  }

  void setBrokeDown(bool value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.conditions.broke = value;
    state = newDoc;
  }

  void setDisconnected(bool value) {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.conditions.disconnect = value;
    state = newDoc;
  }

  void startTimer() {
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    newDoc.teleop.hangTime.start();
    state = newDoc;
  }

  void stopTimer() {
    state.teleop.hangTime.stop();
    ScoutingDocument newDoc = ScoutingDocument.from(state);
    state = newDoc;
  }
}

void main() async {
  runApp(ProviderScope(child: BirdsEye()));
}

class BirdsEye extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DocumentList());
  }
}

class DocumentList extends ConsumerWidget {
  const DocumentList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Database db = ref.watch(dbProvider);
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Birdseye'))),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text('No Folder Selected'),
              ElevatedButton(
                  onPressed: () async {
                    String? path = await FilesystemPicker.open(
                        title: 'Save Folder',
                        context: context,
                        rootDirectory: await getApplicationDocumentsDirectory(),
                        fsType: FilesystemType.folder,
                        pickText: 'Save documents to this folder');
                    if (path != null) {
                      ref.read(dbProvider.notifier).setSavingPath(path);
                    }
                  },
                  child: const Text('Select Folder'))
            ])),
        floatingActionButton: (() {
          // if (folder.length > 0) {
          //   return FloatingActionButton(
          //       onPressed: () {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => DocumentEditor()));
          //       },
          //       child: const Icon(Icons.add));
          // }
        })());
  }
}

class DocumentEditor extends ConsumerWidget {
  DocumentEditor({Key? key}) : super(key: key);
  final TextEditingController _matchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(currentDocumentProvider);
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('New Document'))),
        body: ListView(children: [
          Column(children: [
            Container(
                padding: EdgeInsets.only(top: 20),
                child: Text('Match Data', style: TextStyle(fontSize: 20))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: TextField(
                          onChanged: (value) {
                            if (value.length > 0) {
                              doc.match = int.parse(value);
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Match #'),
                        ))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: TextField(
                            onChanged: (value) {
                              if (value.length > 0) {
                                doc.team = int.parse(value);
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Team #')))),
              ],
            ),
            Container(
                padding: EdgeInsets.only(top: 20),
                child: Text('Autonomous Data', style: TextStyle(fontSize: 20))),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('Taxied'),
                        Switch(
                            value: doc.auto.taxied,
                            onChanged: (value) {
                              ref
                                  .read(currentDocumentProvider.notifier)
                                  .setTaxied(value);
                            })
                      ]),
                      Column(children: [
                        Text('Shooting Distance'),
                        DropdownButton<ShootingDistance>(
                          value: doc.auto.shootingDistance,
                          items: <ShootingDistance>[...ShootingDistance.values]
                              .map<DropdownMenuItem<ShootingDistance>>(
                                  (ShootingDistance value) {
                            return DropdownMenuItem<ShootingDistance>(
                                child: ShootingDistanceLabels[value] == null
                                    ? Text(value.name)
                                    : Text(ShootingDistanceLabels[value]
                                        .toString()),
                                value: value);
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(currentDocumentProvider.notifier)
                                  .setAutoShootingDistance(value);
                            }
                          },
                        )
                      ])
                    ])),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('Lower Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .removeAutoAttemptLower();
                                },
                                child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: doc.auto.cargoLower.toString()),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addAutoScoredLower();
                                },
                                child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addAutoAttemptedLower();
                                },
                                child: const Text('Attempt'))
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .removeAutoAttemptUpper();
                                },
                                child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: doc.auto.cargoUpper.toString()),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addAutoScoredUpper();
                                },
                                child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addAutoAttemptedUpper();
                                },
                                child: const Text('Attempt'))
                          ],
                        )
                      ]),
                    ])),
            Container(
                padding: EdgeInsets.only(top: 20),
                child: Text('Tele-Operation Data',
                    style: TextStyle(fontSize: 20))),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('Lower Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .removeTeleopAttemptLower();
                                },
                                child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: doc.teleop.cargoLower.toString()),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addTeleopScoredLower();
                                },
                                child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addTeleopAttemptedLower();
                                },
                                child: const Text('Attempt'))
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .removeTeleopAttemptUpper();
                                },
                                child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: doc.teleop.cargoUpper.toString()),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addTeleopScoredUpper();
                                },
                                child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(currentDocumentProvider.notifier)
                                      .addTeleopAttemptedUpper();
                                },
                                child: const Text('Attempt'))
                          ],
                        )
                      ]),
                    ])),
            Center(
                child: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Text('Shooting Distance'),
                DropdownButton<ShootingDistance>(
                  value: doc.teleop.shootingDistance,
                  items: <ShootingDistance>[...ShootingDistance.values]
                      .map<DropdownMenuItem<ShootingDistance>>(
                          (ShootingDistance value) {
                    return DropdownMenuItem<ShootingDistance>(
                        child: ShootingDistanceLabels[value] == null
                            ? Text(value.name)
                            : Text(ShootingDistanceLabels[value].toString()),
                        value: value);
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(currentDocumentProvider.notifier)
                          .setTeleopShootingDistance(value);
                    }
                  },
                )
              ]),
            )),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('Hang Choice'),
                        DropdownButton<HangingChoice>(
                          value: doc.teleop.hangingChoice,
                          items: <HangingChoice>[...HangingChoice.values]
                              .map<DropdownMenuItem<HangingChoice>>(
                                  (HangingChoice value) {
                            return DropdownMenuItem<HangingChoice>(
                                child: HangingChoiceLabels[value] == null
                                    ? Text(value.name)
                                    : Text(
                                        HangingChoiceLabels[value].toString()),
                                value: value);
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(currentDocumentProvider.notifier)
                                  .setHangChoice(value);
                            }
                          },
                        )
                      ]),
                      Column(children: [
                        Text('Hang Completed'),
                        DropdownButton<HangingCompletion>(
                          value: doc.teleop.hangingCompletion,
                          items: <HangingCompletion>[
                            ...HangingCompletion.values
                          ].map<DropdownMenuItem<HangingCompletion>>(
                              (HangingCompletion value) {
                            return DropdownMenuItem<HangingCompletion>(
                                child: HangingCompletionLabels[value] == null
                                    ? Text(value.name)
                                    : Text(HangingCompletionLabels[value]
                                        .toString()),
                                value: value);
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(currentDocumentProvider.notifier)
                                  .setHangCompletion(value);
                            }
                          },
                        )
                      ]),
                      Column(
                        children: [
                          Text('Hang Time'),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                  onPressed: () {
                                    if (doc.teleop.hangTime.isRunning) {
                                      ref
                                          .read(
                                              currentDocumentProvider.notifier)
                                          .stopTimer();
                                    } else {
                                      ref
                                          .read(
                                              currentDocumentProvider.notifier)
                                          .startTimer();
                                    }
                                  },
                                  icon: Icon(doc.teleop.hangTime.isRunning
                                      ? Icons.stop
                                      : (doc.teleop.hangTime
                                                  .elapsedMilliseconds >
                                              0
                                          ? Icons.refresh
                                          : Icons.play_arrow)),
                                  label: doc.teleop.hangTime.isRunning
                                      ? const Text('Timer Running')
                                      : (doc.teleop
                                                  .hangTime.elapsedMilliseconds >
                                              0
                                          ? Text(doc.teleop.hangTime.elapsed
                                              .toString())
                                          : Text('Start Timer'))),
                            ],
                          )
                        ],
                      )
                    ])),
            Container(
                padding: EdgeInsets.only(top: 20),
                child:
                    Text('Miscellaneous Data', style: TextStyle(fontSize: 20))),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Broke Down'),
                          Switch(
                              value: doc.conditions.broke,
                              onChanged: (value) {
                                ref
                                    .read(currentDocumentProvider.notifier)
                                    .setBrokeDown(value);
                              })
                        ],
                      ),
                      Column(
                        children: [
                          Text('Disconnected'),
                          Switch(
                              value: doc.conditions.disconnect,
                              onChanged: (value) {
                                ref
                                    .read(currentDocumentProvider.notifier)
                                    .setDisconnected(value);
                              })
                        ],
                      )
                    ])),
            Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: TextEditingController(text: doc.comments),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Comments',
                  ),
                  onChanged: (value) {
                    doc.comments = value;
                  },
                ))
          ]),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.save)));
  }
}
