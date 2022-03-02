import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

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

class AutoSection {
  final bool taxied;
  final int cargoLower;
  final int cargoUpper;
  final ShootingDistance shootingDistance;

  const AutoSection(
      {required this.taxied,
      required this.cargoLower,
      required this.cargoUpper,
      required this.shootingDistance});
}

class TeleopSection {
  final ShootingDistance shootingDistance;
  final int cargoLower;
  final int cargoUpper;
  final HangingChoice hangingChoice;
  final HangingCompletion hangingCompletion;

  const TeleopSection(
      {required this.shootingDistance,
      required this.cargoLower,
      required this.cargoUpper,
      required this.hangingChoice,
      required this.hangingCompletion});
}

class Conditions {
  final bool broke;
  final bool disconnect;

  const Conditions({required this.broke, required this.disconnect});
}

class ScoutingDocument {
  final int id;
  final int team;
  final int match;
  final AutoSection auto;
  final TeleopSection teleop;
  final Conditions conditions;
  final String comments;

  const ScoutingDocument(
      {required this.id,
      required this.team,
      required this.match,
      required this.auto,
      required this.teleop,
      required this.conditions,
      required this.comments});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'team': this.team,
      'match': this.match,
      'autoTaxied': this.auto.taxied ? 1 : 0,
      'autoCargoLower': this.auto.cargoLower,
      'autoCargoUpper': this.auto.cargoUpper,
      'autoShootingDistance': this.auto.shootingDistance.index,
      'teleShootingDistance': this.teleop.shootingDistance.index,
      'teleCargoLower': this.teleop.cargoLower,
      'teleCargoupper': this.teleop.cargoUpper,
      'teleHangingChoice': this.teleop.hangingChoice.index,
      'teleHangingCompletion': this.teleop.hangingCompletion.index,
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

final dbProvider = ChangeNotifierProvider<DatabaseProvider>((ref) {
  return DatabaseProvider();
});

final currentDocumentProvider = Provider<ScoutingDocument>((ref) {
  return ScoutingDocument(
      id: 1,
      team: 0,
      match: 0,
      auto: AutoSection(
          taxied: false,
          cargoLower: 0,
          cargoUpper: 0,
          shootingDistance: ShootingDistance.varies),
      teleop: TeleopSection(
        shootingDistance: ShootingDistance.varies,
        cargoLower: 0,
        cargoUpper: 0,
        hangingChoice: HangingChoice.low,
        hangingCompletion: HangingCompletion.noAttempt,
      ),
      conditions: Conditions(broke: false, disconnect: false),
      comments: "");
});

class DatabaseProvider with ChangeNotifier {
  static final tableName = 'scouting';
  late sql.Database db;

  DatabasePrivder() {
    init();
  }

  void init() async {
    final dbPath = await sql.getDatabasesPath();
    db = await sql.openDatabase(path.join(dbPath, 'scouting_db.sqlite'),
        version: 2, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE scouting(id INTEGER PRIMARY KEY, team INTEGER, match INTEGER, autoTaxied INTEGER, autoCargoLower INTEGER, autoCargoUpper INTEGER, autoShootingDistance INTEGER, teleShootingDistance INTEGER, teleCargoLower INTEGER, teleCargoUpper INTEGER, teleHangingChoice INTEGER, teleHangingCompletion INTEGER, broke INTEGER, disconnect INTEGER, comments TEXT)');
    });
    notifyListeners();
  }

  Future<void> insert(ScoutingDocument doc) async {
    await db.insert(tableName, doc.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<List<ScoutingDocument>> list() async {
    final List<Map<String, dynamic>> docs = await db.query(tableName);
    return List.generate(docs.length, (index) {
      return ScoutingDocument(
          id: docs[index]['id'],
          team: docs[index]['team'],
          match: docs[index]['match'],
          auto: AutoSection(
              taxied: docs[index]['autoTaxied'],
              cargoLower: docs[index]['autoCargoLower'],
              cargoUpper: docs[index]['autoCargoUpper'],
              shootingDistance:
                  ShootingDistance.values[docs[index]['autoShootingDistance']]),
          teleop: TeleopSection(
              shootingDistance:
                  ShootingDistance.values[docs[index]['teleShootingDistance']],
              cargoLower: docs[index]['teleCargoLower'],
              cargoUpper: docs[index]['teleCargoUpper'],
              hangingChoice:
                  HangingChoice.values[docs[index]['teleHangingChoice']],
              hangingCompletion: HangingCompletion
                  .values[docs[index]['teleHangingCompletion']]),
          conditions: Conditions(
              broke: docs[index]['broke'],
              disconnect: docs[index]['disconnect']),
          comments: docs[index]['comments']);
    });
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
        body: Center(child: Text('No Documents')),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DocumentEditor()));
            },
            child: const Icon(Icons.add)));
  }
}

class DocumentEditor extends ConsumerWidget {
  const DocumentEditor({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(currentDocumentProvider);
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('New Document'))),
        body: PageView(children: [
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Match #'),
                        ))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: TextField(
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
                        Switch(value: doc.auto.taxied, onChanged: (value) {})
                      ]),
                      Column(children: [
                        Text('Shooting Distance'),
                        DropdownButton<ShootingDistance>(
                          value: ShootingDistance.varies,
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
                          onChanged: (value) {},
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
                                onPressed: () {}, child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('+')),
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {}, child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('+')),
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
                                onPressed: () {}, child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('+')),
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Upper Cargo Scored'),
                        Row(
                          children: [
                            OutlinedButton(
                                onPressed: () {}, child: const Text('-')),
                            SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('+')),
                          ],
                        )
                      ]),
                      Column(children: [
                        Text('Shooting Distance'),
                        DropdownButton<ShootingDistance>(
                          value: ShootingDistance.varies,
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
                          onChanged: (value) {},
                        )
                      ]),
                    ])),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('Hang Choice'),
                        DropdownButton<HangingChoice>(
                          value: HangingChoice.low,
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
                          onChanged: (value) {},
                        )
                      ]),
                      Column(children: [
                        Text('Hang Completed'),
                        DropdownButton<HangingCompletion>(
                          value: HangingCompletion.noAttempt,
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
                          onChanged: (value) {},
                        )
                      ]),
                      Column(
                        children: [
                          Text('Hang Time'),
                          OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Timer'))
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
                          Switch(value: false, onChanged: (value) {})
                        ],
                      ),
                      Column(
                        children: [
                          Text('Disconnected'),
                          Switch(value: false, onChanged: (value) {})
                        ],
                      )
                    ])),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Comments',
              ),
            )
          ])
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.save)));
  }
}
