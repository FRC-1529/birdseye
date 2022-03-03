import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'document.dart';

final folderProvider = StateNotifierProvider<Folder, String>((ref) {
  return Folder();
});

class Folder extends StateNotifier<String> {
  Folder() : super("");

  void setPath(String path) {
    state = path;
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
            comments: ""));

  void setTeam(int team) => state.team = team;
  void setTaxied(bool value) {}
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
    String folder = ref.watch(folderProvider);
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Birdseye'))),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              if (folder.length > 0) Text(folder),
              if (folder.length == 0) ...[
                Text('No Folder Selected'),
                ElevatedButton(
                    onPressed: () async {
                      String? path = await FilesystemPicker.open(
                          title: 'Save Folder',
                          context: context,
                          rootDirectory:
                              await getApplicationDocumentsDirectory(),
                          fsType: FilesystemType.folder,
                          pickText: 'Save documents to this folder');
                      if (path != null) {
                        ref.read(folderProvider.notifier).setPath(path);
                      }
                    },
                    child: const Text('Select Folder'))
              ]
            ])),
        floatingActionButton: (() {
          if (folder.length > 0) {
            return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DocumentEditor()));
                },
                child: const Icon(Icons.add));
          }
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
                                doc.match = int.parse(value);
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
                              print(value);
                              ref
                                  .read(currentDocumentProvider.notifier)
                                  .setTaxied(value);
                              print(doc);
                            })
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
                                  controller:
                                      TextEditingController(text: '0/0'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Attempt'))
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
                                  controller:
                                      TextEditingController(text: '0/0'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Attempt'))
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
                                  controller:
                                      TextEditingController(text: '0/0'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Attempt'))
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
                                  controller:
                                      TextEditingController(text: '0/0'),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                )),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Scored')),
                            OutlinedButton(
                                onPressed: () {}, child: const Text('Attempt'))
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
                  value: ShootingDistance.varies,
                  items: <ShootingDistance>[...ShootingDistance.values]
                      .map<DropdownMenuItem<ShootingDistance>>(
                          (ShootingDistance value) {
                    return DropdownMenuItem<ShootingDistance>(
                        child: ShootingDistanceLabels[value] == null
                            ? Text(value.name)
                            : Text(ShootingDistanceLabels[value].toString()),
                        value: value);
                  }).toList(),
                  onChanged: (value) {},
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
            Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Comments',
                  ),
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
