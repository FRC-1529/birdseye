import 'package:birdseye/scouting.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'enums.dart';

final dbProvider = StateNotifierProvider<DatabaseHandler, Database>((ref) {
  return DatabaseHandler();
});

class DatabaseHandler extends StateNotifier<Database> {
  DatabaseHandler() : super(Database());

  void openDatabase(String path) {
    Database db = Database(dir: path);
    db.searchRoot();
    state = db;
  }

  void saveDocument(ScoutingDocument doc) {
    Database db = Database.from(state);
    //If team doest exist, create it.
    Iterable<TeamDocument> teamExists =
        db.teams.where((el) => el.team == doc.team);
    if (teamExists.isEmpty) {
      TeamDocument newTeam = TeamDocument(team: doc.team, docs: [doc]);
      db.teams.add(newTeam);
      state = db;
      return;
    }
    //If team exists, locate it;
    TeamDocument team = teamExists.first;
    int location = db.teams.indexOf(team);
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
    db.teams[location] = team;
    db.saveToDisk();
    state = db;
  }
}

final documentProvider =
    StateNotifierProvider<DocumentHandler, ScoutingDocument>((ref) {
  return DocumentHandler();
});

class DocumentHandler extends StateNotifier<ScoutingDocument> {
  DocumentHandler() : super(ScoutingDocument());

  void createNewDocument() {
    state = new ScoutingDocument();
  }

  void setDocument(ScoutingDocument doc) {
    state = doc;
  }

  void setTeam(String value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.team = value;
    state = doc;
  }

  void setMatch(String value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.match = value;
    state = doc;
  }

  void setAutoTaxied(bool value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.taxied = value;
    state = doc;
  }

  void setAutoShootingDistance(ShootingDistance value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.distance = value;
    state = doc;
  }

  void incrementAutoLowerScored() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.lower.scored++;
    state = doc;
  }

  void incrementAutoLowerAttempt() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.lower.attempted++;
    state = doc;
  }

  void incrementAutoUpperScored() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.upper.scored++;
    state = doc;
  }

  void incrementAutoUpperAttempt() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.auto.upper.attempted++;
    state = doc;
  }

  void incrementTeleopLowerScored() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.lower.scored++;
    state = doc;
  }

  void incrementTeleopLowerAttempt() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.lower.attempted++;
    state = doc;
  }

  void incrementTeleopUpperScored() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.upper.scored++;
    state = doc;
  }

  void incrementTeleopUpperAttempt() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.upper.attempted++;
    state = doc;
  }

  void setTeleopShootingDistance(ShootingDistance value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.distance = value;
    state = doc;
  }

  void setTeleopHangSelection(HangingSelection value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.hang.selection = value;
    state = doc;
  }

  void setTeleopHangCompletion(HangingCompletion value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.hang.completion = value;
    state = doc;
  }

  void startTeleopHangTimer() {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.teleop.hang.stopwatch = Stopwatch();
    doc.teleop.hang.stopwatch?.start();
    state = doc;
  }

  void stopTeleopHangTimer() {
    state.teleop.hang.stopwatch?.stop();
    state.teleop.hang.time = state.teleop.hang.stopwatch!.elapsedMilliseconds;
    state.teleop.hang.stopwatch?.reset();
    ScoutingDocument doc = ScoutingDocument.from(state);
    state = doc;
  }

  void setBroke(bool value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.broke = value;
    state = doc;
  }

  void setDisconnected(bool value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.disconnected = value;
    state = doc;
  }

  void setComments(String value) {
    ScoutingDocument doc = ScoutingDocument.from(state);
    doc.comments = value;
    state = doc;
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
    final db = ref.watch(dbProvider);
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Birdseye'))),
        body: (() {
          if (db.teams.length > 0) {
            return ListView(
              children: List.generate(db.teams.length, (teamI) {
                return Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Team #${db.teams[teamI].team}',
                              style: Theme.of(context).textTheme.headline4),
                          ...List.generate(db.teams[teamI].docs.length, (docI) {
                            return Card(
                                child: InkWell(
                                    onTap: () {
                                      ref
                                          .read(documentProvider.notifier)
                                          .setDocument(
                                              db.teams[teamI].docs[docI]);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DocumentEditor()));
                                    },
                                    child: SizedBox(
                                        height: 50,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                  'Match #${db.teams[teamI].docs[docI].match}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge)
                                            ]))));
                          })
                        ]));
              }),
            );
          } else {
            if (db.rootDir != null) {
              if (db.rootDir!.existsSync()) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Text("No Documents Found")),
                        ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(documentProvider.notifier)
                                  .createNewDocument();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DocumentEditor()));
                            },
                            child: const Text("Create First Document"))
                      ]),
                );
              }
            } else {
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          child: Text("No Save Folder Selected")),
                      ElevatedButton(
                          onPressed: () async {
                            String? selectedPath = await FilesystemPicker.open(
                                title: 'Save Folder',
                                context: context,
                                rootDirectory:
                                    await getApplicationDocumentsDirectory(),
                                fsType: FilesystemType.folder,
                                pickText: 'Save documents to this folder');
                            if (selectedPath != null) {
                              final pref =
                                  await SharedPreferences.getInstance();
                              await pref.setString('saveDir', selectedPath);
                              ref
                                  .read(dbProvider.notifier)
                                  .openDatabase(selectedPath);
                            }
                          },
                          child: const Text("Select Folder"))
                    ]),
              );
            }
          }
        })(),
        floatingActionButton: (() {
          if (db.rootDir != null) {
            if (db.rootDir!.existsSync()) {
              return FloatingActionButton(
                  onPressed: () {
                    ref.read(documentProvider.notifier).createNewDocument();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DocumentEditor()));
                  },
                  child: const Icon(Icons.add));
            }
          }
        })());
  }
}

class DocumentEditor extends ConsumerWidget {
  DocumentEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(documentProvider);
    final _matchController = TextEditingController(text: doc.match);
    final _teamController = TextEditingController(text: doc.team);
    final _commentsController = TextEditingController(text: doc.comments);
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
                          controller: _matchController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Match #'),
                        ))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: TextField(
                            controller: _teamController,
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
                                  .read(documentProvider.notifier)
                                  .setTeam(_teamController.text);
                              ref
                                  .read(documentProvider.notifier)
                                  .setMatch(_matchController.text);
                              ref
                                  .read(documentProvider.notifier)
                                  .setComments(_commentsController.text);
                              ref
                                  .read(documentProvider.notifier)
                                  .setAutoTaxied(value);
                            })
                      ]),
                      Column(children: [
                        Text('Shooting Distance'),
                        DropdownButton<ShootingDistance>(
                          value: doc.auto.distance,
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
                            ref
                                .read(documentProvider.notifier)
                                .setTeam(_teamController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setMatch(_matchController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setComments(_commentsController.text);
                            if (value != null)
                              ref
                                  .read(documentProvider.notifier)
                                  .setAutoShootingDistance(value);
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
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${doc.auto.lower.toString()}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                )),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementAutoLowerScored();
                                            },
                                            child: const Text('Scored'))),
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementAutoLowerAttempt();
                                            },
                                            child: const Text('Attempt'))),
                                  ],
                                ))
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${doc.auto.upper.toString()}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                  enabled: false,
                                )),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementAutoUpperScored();
                                            },
                                            child: const Text('Scored'))),
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementAutoUpperAttempt();
                                            },
                                            child: const Text('Attempt'))),
                                  ],
                                ))
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
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${doc.teleop.lower.toString()}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                  enabled: false,
                                )),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementTeleopLowerScored();
                                            },
                                            child: const Text('Scored'))),
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementTeleopLowerAttempt();
                                            },
                                            child: const Text('Attempt'))),
                                  ],
                                ))
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${doc.teleop.upper.toString()}'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                  enabled: false,
                                )),
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementTeleopUpperScored();
                                            },
                                            child: const Text('Scored'))),
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setTeam(
                                                      _teamController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setMatch(
                                                      _matchController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .setComments(
                                                      _commentsController.text);
                                              ref
                                                  .read(
                                                      documentProvider.notifier)
                                                  .incrementTeleopUpperAttempt();
                                            },
                                            child: const Text('Attempt'))),
                                  ],
                                ))
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
                  value: doc.teleop.distance,
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
                    ref
                        .read(documentProvider.notifier)
                        .setTeam(_teamController.text);
                    ref
                        .read(documentProvider.notifier)
                        .setMatch(_matchController.text);
                    ref
                        .read(documentProvider.notifier)
                        .setComments(_commentsController.text);
                    if (value != null)
                      ref
                          .read(documentProvider.notifier)
                          .setTeleopShootingDistance(value);
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
                        Text('Hanging Selection'),
                        DropdownButton<HangingSelection>(
                          value: doc.teleop.hang.selection,
                          items: <HangingSelection>[...HangingSelection.values]
                              .map<DropdownMenuItem<HangingSelection>>(
                                  (HangingSelection value) {
                            return DropdownMenuItem<HangingSelection>(
                                child: HangingSelectionLabels[value] == null
                                    ? Text(value.name)
                                    : Text(HangingSelectionLabels[value]
                                        .toString()),
                                value: value);
                          }).toList(),
                          onChanged: (value) {
                            ref
                                .read(documentProvider.notifier)
                                .setTeam(_teamController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setMatch(_matchController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setComments(_commentsController.text);
                            if (value != null)
                              ref
                                  .read(documentProvider.notifier)
                                  .setTeleopHangSelection(value);
                          },
                        )
                      ]),
                      Column(children: [
                        Text('Hanging Completion'),
                        DropdownButton<HangingCompletion>(
                          value: doc.teleop.hang.completion,
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
                            ref
                                .read(documentProvider.notifier)
                                .setTeam(_teamController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setMatch(_matchController.text);
                            ref
                                .read(documentProvider.notifier)
                                .setComments(_commentsController.text);
                            if (value != null)
                              ref
                                  .read(documentProvider.notifier)
                                  .setTeleopHangCompletion(value);
                          },
                        )
                      ]),
                      Column(
                        children: [
                          Text('Hanging Timer'),
                          Row(
                            children: [
                              OutlinedButton.icon(onPressed: () {
                                ref
                                    .read(documentProvider.notifier)
                                    .setTeam(_teamController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setMatch(_matchController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setComments(_commentsController.text);
                                if (doc.teleop.hang.stopwatch != null) {
                                  if (doc.teleop.hang.stopwatch!.isRunning) {
                                    ref
                                        .read(documentProvider.notifier)
                                        .stopTeleopHangTimer();
                                    return;
                                  }
                                  ref
                                      .read(documentProvider.notifier)
                                      .startTeleopHangTimer();
                                  return;
                                }
                                ref
                                    .read(documentProvider.notifier)
                                    .startTeleopHangTimer();
                              }, icon: Icon((() {
                                if (doc.teleop.hang.stopwatch != null) {
                                  if (doc.teleop.hang.stopwatch!.isRunning) {
                                    return Icons.stop;
                                  }
                                  if (doc.teleop.hang.time > 0) {
                                    return Icons.refresh;
                                  }
                                  return Icons.play_arrow;
                                }
                                return Icons.play_arrow;
                              })()), label: Text((() {
                                if (doc.teleop.hang.stopwatch != null) {
                                  if (doc.teleop.hang.stopwatch!.isRunning) {
                                    return "Running";
                                  }
                                  if (doc.teleop.hang.time > 0) {
                                    return doc.teleop.hang.timeString();
                                  }
                                  return "Start Timer";
                                }
                                return "Start Timer";
                              })())),
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
                              value: doc.broke,
                              onChanged: (value) {
                                ref
                                    .read(documentProvider.notifier)
                                    .setTeam(_teamController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setMatch(_matchController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setComments(_commentsController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setBroke(value);
                              })
                        ],
                      ),
                      Column(
                        children: [
                          Text('Disconnected'),
                          Switch(
                              value: doc.disconnected,
                              onChanged: (value) {
                                ref
                                    .read(documentProvider.notifier)
                                    .setTeam(_teamController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setMatch(_matchController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setComments(_commentsController.text);
                                ref
                                    .read(documentProvider.notifier)
                                    .setDisconnected(value);
                              })
                        ],
                      )
                    ])),
            Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  controller: _commentsController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Comments',
                  ),
                ))
          ]),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              doc.team = _teamController.text;
              doc.match = _matchController.text;
              doc.comments = _commentsController.text;
              ref.read(dbProvider.notifier).saveDocument(doc);
              Navigator.pop(context);
            },
            child: const Icon(Icons.save)));
  }
}
