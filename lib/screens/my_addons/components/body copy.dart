// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as path;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:wow_addon_updater/components/download_file.dart';

// import '../../../config.dart';
// import '../../../models/current_addons.dart';
// import '../../../models/get_addons.dart';

// class Body extends StatefulWidget {
//   @override
//   _BodyState createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   bool sort = true;
//   int colIndex = 0;
//   Future<List<CurrentAddons>> futureCurrentAddons;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     futureCurrentAddons = fetchCurrentAddons();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: FutureBuilder(
//         future: futureCurrentAddons,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             //print(snapshot.data);
//             return Column(
//               //mainAxisSize: MainAxisSize.max,
//               //mainAxisAlignment: MainAxisAlignment.center,
//               //verticalDirection: VerticalDirection.down,

//               children: <Widget>[
//                 Expanded(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: EdgeInsets.all(10),
//                     child: buildSingleChildScrollView(snapshot.data),
//                     //child: Text('Hello'),
//                   ),
//                 )
//               ],
//             );
//           } else if (snapshot.hasError) {
//             return Text("ERROR:  ${snapshot.error}");
//           }
//           // By default, show a loading spinner.
//           return CircularProgressIndicator();
//         },
//       ),
//     );
//   }

//   Future<List<GetAddons>> fetchAddonInfo(String addonName) async {
//     final String _curseAddon = 'https://addons-ecs.forgesvc.net/api/v2/addon/search?gameId=1&categoryId=0&searchFilter=${Uri.parse(addonName)}';
//     final response = await http.get(_curseAddon);
//     List<GetAddons> listOfAddons;
//     //print(_curseAddon);

//     if (response.statusCode == 200) {
//       print('Curse Success');
//       // If the server did return a 200 OK response,d
//       // then parse the JSON.
//       if ((json.decode(response.body) as List).map((i) => GetAddons.fromJson(i)).toList().isNotEmpty) {
//         listOfAddons = (json.decode(response.body) as List).map((i) => GetAddons.fromJson(i)).toList();
//         return listOfAddons;
//       } else {
//         return null;
//       }
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       throw Exception(json.decode(response.body));
//     }
//   }

//   onSortColumn(int columnIndex, bool ascending, List<CurrentAddons> snapshot) {
//     if (columnIndex >= 0) {
//       if (ascending) {
//         snapshot.sort((a, b) => a.addonName.compareTo(b.addonName));
//       } else {
//         snapshot.sort((a, b) => b.addonName.compareTo(a.addonName));
//       }
//     }
//   }

//   Future<List<CurrentAddons>> fetchCurrentAddons() async {
//     Directory retail = Directory('$defaultWowDir\\dump\\');
//     Directory config = Directory(r'C:\Program Files (x86)\World of Warcraft\_retail_\');
//     List<CurrentAddons> listOfAddons = List<CurrentAddons>();
//     List<CurrentAddons> onPCAddons = List<CurrentAddons>();
//     List<String> addonSearchQuery = List<String>();
//     String currentGameVersion;

//     final file = new File('${config.path}\\WTF\\Config.wtf');
//     List<String> lines = file.readAsLinesSync();
//     lines.forEach((line) {
//       if (line.contains("SET lastAddonVersion ")) {
//         currentGameVersion = line.split("SET lastAddonVersion ")[1].replaceAll("\"", '');
//         //print('currentGameVersion: $currentGameVersion');
//       }
//     });

//     await retail.list().toList().then((value) async {
//       for (var item in value) {
//         if (item.toString().split(":")[0] == "Directory") {
//           String addonFolderName = path.basename(item.path);
//           String currentAddonVersion = "";
//           CurrentAddons currentAddonItem = CurrentAddons();

//           final file = new File('${item.path}\\$addonFolderName.toc');
//           List<String> lines = file.readAsLinesSync();

//           currentAddonItem.onPCFolderName = path.basename(item.path);
//           lines.forEach(
//             (line) {
//               if (line.contains("## Interface: ") && currentAddonItem.currentAddonGameVersion == null) {
//                 currentAddonItem.currentAddonGameVersion = line.split("## Interface: ")[1];
//               }
//               if (line.contains("## Version: ") && currentAddonItem.onPCVersion == null) {
//                 currentAddonItem.onPCVersion = line.split("## Version: ")[1];
//               }
//               if (line.contains("## Title: ") && currentAddonItem.onPCTocTitle == null) {
//                 currentAddonItem.onPCTocTitle = line.split("Title: ")[1].replaceAll(new RegExp(r'[^\w\s]+'), '');
//               }
//               if (line.contains("## Dependencies: ") && currentAddonItem.onPCDependencies == null) {
//                 currentAddonItem.onPCDependencies = line.split("Dependencies: ")[1].replaceAll(new RegExp(r'[^\w\s]+'), '');
//               }
//             },
//           );
//           if (currentAddonItem.onPCDependencies == null) {
//             //print(currentAddonItem.toJson());
//             onPCAddons.add(currentAddonItem);
//             addonSearchQuery.add(currentAddonItem.onPCFolderName);
//           }
//         }
//       }
//     });

//     await fetchAddonInfo(addonSearchQuery.join(",")).then((data) {
//       // await fetchAddonInfo(addonSearchQuery.join(",")).then((data) {
//       //   if (data != null) {
//       //     for (var value in data) {
//       //       int latestFileIndex;
//       //       String foundAddon;
//       //       int latestModuleIndex;

//       //       latestFileIndex = value.latestFiles.indexWhere((element) => element.releaseType == 1 && element.gameVersionFlavor == 'wow_retail');
//       //       //print('latestFileIndex: $latestFileIndex');
//       //       if (latestFileIndex != -1) {
//       //         latestModuleIndex = value.latestFiles[latestFileIndex].modules.indexWhere((element) => (element.type == 3));
//       //         //print('latestModuleIndex: $latestModuleIndex');
//       //         if (latestModuleIndex != -1) {
//       //           var foundAddonIndex = addonSearchQuery.indexWhere(
//       //               (element) => (element == value.name || element == value.latestFiles[latestFileIndex].modules[latestModuleIndex].foldername));
//       //           if (foundAddonIndex != -1) foundAddon = addonSearchQuery[foundAddonIndex];
//       //           String mainFolder = value.latestFiles[latestFileIndex].modules[latestModuleIndex].foldername;

//       //           String thumbnailUrl = 'https://vignette.wikia.nocookie.net/onceuponatime-fanon/images/1/14/No_Image_Available.jpg';
//       //           if (value.attachments.isNotEmpty) {
//       //             int defaultThumbnailIndex = value.attachments.indexWhere((element) => element.isDefault);
//       //             if (defaultThumbnailIndex == -1) {
//       //               thumbnailUrl = value.attachments[0].thumbnailUrl;
//       //             } else {
//       //               thumbnailUrl = value.attachments[defaultThumbnailIndex].thumbnailUrl;
//       //             }
//       //           }
//       //           if ((mainFolder == foundAddon || value.name == foundAddon || value.name == mainFolder) &&
//       //               !value.slug.contains('beta') &&
//       //               value.latestFiles[latestFileIndex].gameVersion.isNotEmpty) {
//       //             print('m: $mainFolder');
//       //             int matchIndex = onPCAddons.indexWhere((element) =>
//       //                 element.addonName == value.name || element.addonName == value.latestFiles[latestFileIndex].modules[latestModuleIndex].foldername);
//       //             bool isUpdatedd = true;
//       //             if (matchIndex != -1) {
//       //               print(
//       //                   '${value.name} - onPC: ${onPCAddons[matchIndex].latestVersion} - onServer: ${value.latestFiles[latestFileIndex].displayName}');
//       //               if (onPCAddons[matchIndex].latestVersion.replaceAll('_', '.') ==
//       //                       value.latestFiles[latestFileIndex].displayName.replaceAll('_', '.') ||
//       //                   onPCAddons[matchIndex]
//       //                       .latestVersion
//       //                       .replaceAll('_', '.')
//       //                       .contains(value.latestFiles[latestFileIndex].displayName.replaceAll('_', '.')) ||
//       //                   value.latestFiles[latestFileIndex].displayName
//       //                       .replaceAll('_', '.')
//       //                       .contains(onPCAddons[matchIndex].latestVersion.replaceAll('_', '.'))) {
//       //                 print(
//       //                     '${value.name} - onPC: ${onPCAddons[matchIndex].latestVersion} - onServer: ${value.latestFiles[latestFileIndex].displayName}');
//       //                 isUpdatedd = !isUpdatedd;
//       //               }
//       //             }
//       //             CurrentAddons c = CurrentAddons(
//       //               addonName: value.name,
//       //               btnText: "",
//       //               isUpdated: isUpdatedd,
//       //               thumbnailUrl: thumbnailUrl,
//       //               latestVersion: value.latestFiles[latestFileIndex].displayName,
//       //               gameVersion: value.latestFiles[latestFileIndex].sortableGameVersion[0].gameVersion,
//       //               source: "Curse",
//       //               authors: value.authors[0].name,
//       //               currentAddonGameVersion: currentGameVersion,
//       //               filename: value.latestFiles[latestFileIndex].fileName,
//       //               downloadUrl: value.latestFiles[latestFileIndex].downloadUrl,
//       //             );
//       //             if ((listOfAddons.indexWhere((element) => element.addonName == mainFolder) == -1)) {
//       //               listOfAddons.add(c);
//       //             }
//       //           }
//       //         }
//       //       }
//       //     }
//       //   }
//     });

//     //print(listOfAddons);
//     return listOfAddons;
//   }

//   SingleChildScrollView buildSingleChildScrollView(List<CurrentAddons> snapshot) {
//     int count = 0;
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               FlatButton(
//                 child: Text("Update All", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                 color: Theme.of(context).buttonColor,
//                 onPressed: () {
//                   for (var addon in snapshot) {
//                     setState(() {
//                       addon.isUpdated = !addon.isUpdated;
//                       addon.btnText = "Downloading...";
//                     });
//                     Future.delayed(Duration(seconds: 1)).then((value) {
//                       setState(() {
//                         //downloadFile(currentAddons.latestFiles[_latestVersion].downloadUrl);
//                         addon.btnText = "Up to date";
//                       });
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//           DataTable(
//             sortAscending: sort,
//             sortColumnIndex: colIndex,
//             showCheckboxColumn: false,
//             dataRowHeight: 60,
//             columnSpacing: MediaQuery.of(context).size.width * .095,
//             columns: [
//               buildDataColumn(snapshot, "Addon"),
//               buildDataColumn(snapshot, "Status"),
//               buildDataColumn(snapshot, "Latest Version"),
//               buildDataColumn(snapshot, "Game Version"),
//               buildDataColumn(snapshot, "Source"),
//               buildDataColumn(snapshot, "Author"),
//             ],
//             rows: snapshot.map(
//               (currentAddons) {
//                 count += 1;
//                 //print(currentAddons);
//                 return DataRow(
//                   cells: [
//                     DataCell(
//                       SizedBox(
//                           child: Row(
//                         children: [
//                           Image.network(
//                             currentAddons.thumbnailUrl,
//                             height: 50,
//                             width: 50,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 5),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   currentAddons.addonName,
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text(
//                                   currentAddons.filename,
//                                   //style: TextStyle(color: Colors.black87),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       )),
//                       onTap: () {
//                         //launchInBrowser(addonData.websiteUrl);
//                       },
//                     ),
//                     //DataCell(Text('$count - ${currentAddons.addonName}', overflow: TextOverflow.ellipsis)),
//                     DataCell(
//                       currentAddons.isUpdated
//                           ? FlatButton(
//                               child: Text("Update", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                               color: Theme.of(context).buttonColor,
//                               onPressed: () {
//                                 setState(() {
//                                   currentAddons.isUpdated = !currentAddons.isUpdated;
//                                   currentAddons.btnText = "Downloading...";
//                                 });
//                                 print(currentAddons.downloadUrl);
//                                 var dio = Dio();
//                                 String currentDirectory = Directory.current.path;

//                                 //downloadFile(false, true, '$defaultWowDir\\dump\\', '$defaultWowDir\\dump\\', currentAddons.downloadUrl)
//                                 downloadUpdate(
//                                   isUnzip: true,
//                                   isAppUpdate: false,
//                                   dio: dio,
//                                   url: currentAddons.downloadUrl,
//                                   savePath: '$defaultWowDir\\dump\\',
//                                 ).then((value) {
//                                   String newBtnText;
//                                   if (value == 'OK') {
//                                     newBtnText = 'Up to date';
//                                   } else {
//                                     newBtnText = value;
//                                   }
//                                   setState(() {
//                                     //currentAddons.isUpdated = !currentAddons.isUpdated;
//                                     currentAddons.btnText = newBtnText;
//                                   });
//                                 });
//                               },
//                             )
//                           : SizedBox(
//                               child: Text(currentAddons.btnText),
//                               // width: MediaQuery.of(context).size.width * 0.1,
//                             ),
//                     ),
//                     DataCell(Text(currentAddons.latestVersion, overflow: TextOverflow.ellipsis)),
//                     DataCell(Text(currentAddons.gameVersion, overflow: TextOverflow.ellipsis)),
//                     DataCell(Text(currentAddons.source, overflow: TextOverflow.ellipsis)),
//                     DataCell(Text(currentAddons.authors, overflow: TextOverflow.ellipsis)),
//                   ],
//                 );
//               },
//             ).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   DataColumn buildDataColumn(List<CurrentAddons> snapshot, String label) {
//     return DataColumn(
//         label: Text(
//           label,
//           style: TextStyle(fontWeight: FontWeight.bold),
//           overflow: TextOverflow.ellipsis,
//         ),
//         onSort: (columnIndex, sortAscending) {
//           setState(() {
//             sort = !sort;
//             colIndex = 0;
//           });
//           onSortColumn(colIndex, sort, snapshot);
//         });
//   }
// }
