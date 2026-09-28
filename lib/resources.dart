import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jeecurisedesk/main.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const Resources());
}

String tasks = "";

class Resources extends StatelessWidget {
  const Resources({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'JeSecurise Desk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  //----------------------------------------------- startup -----------------------------------------------------

  static const platform2 = MethodChannel('com.example.startup');

  Future<List<String>> getStartupFiles() async {
    try {
      final List<dynamic> result =
          await platform2.invokeMethod('getStartupFiles');
      return result.map((item) => item.toString()).toList();
    } on PlatformException catch (e) {
      print("Failed to get startup files: '${e.message}'.");
      return [];
    }
  }

  //----------------------------------------------- startup -----------------------------------------------------

  //----------------------------------------------- schedules -----------------------------------------------------
  static const platform = MethodChannel('com.example/schtasks');

  Future<String> queryScheduledTasks() async {
    try {
      final String result = await platform.invokeMethod('queryTasks');
      tasks = result;
      return result;
    } on PlatformException catch (e) {
      tasks = e.message ?? "error";
      return "Failed to query tasks: '${e.message}'.";
    }
  }
  //----------------------------------------------- schedules -----------------------------------------------------

  //----------------------------------------------- hdd -----------------------------------------------------
  String diskUsage = 'Calculating...';

  // @override
  // void initState() {
  //   super.initState();
  //   getDiskUsage();
  // }

  Future<void> getDiskUsage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final totalSpace = await _getTotalSpace(appDir);
      final freeSpace = await _getFreeSpace(appDir);

      setState(() {
        diskUsage = 'Total Space: ${_formatBytes(totalSpace)}\n'
            'Free Space: ${_formatBytes(freeSpace)}';
      });
    } catch (e) {
      setState(() {
        diskUsage = 'Error retrieving disk usage: $e';
      });
    }
  }

  Future<int> _getTotalSpace(Directory dir) async {
    // Implement platform-specific code to get total space here
    // Example for Android:
    // return (await Directory(dir.path).stat()).size;
    return 0; // Placeholder value
  }

  Future<int> _getFreeSpace(Directory dir) async {
    // Implement platform-specific code to get free space here
    // Example for Android:
    // return (await Directory(dir.path).stat()).size;
    return 0; // Placeholder value
  }

  String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes / 3).floor();
    final size = bytes / 1024;
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  //----------------------------------------------- hdd -----------------------------------------------------

  VmService? vmService;
  Timer? timer;
  int usedHeap = 0;

  @override
  void initState() {
    super.initState();
    connectToVmService();
    getDiskUsage();
    queryScheduledTasks();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void connectToVmService() async {
    final info = await developer.Service.getInfo();
    final uri = info.serverUri;
    if (uri != null) {
      vmService = await vmServiceConnectUri(
        'ws://${uri.host}:${uri.port}${info.serverUri?.path}/ws',
      );
      startMemoryUsageMonitoring();
    }
  }

  void startMemoryUsageMonitoring() {
    timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      if (vmService != null) {
        final allocationProfile =
            await vmService!.getAllocationProfile('isolateId', reset: true);
        setState(() {
          usedHeap = allocationProfile.memoryUsage?.heapUsage ?? 0;
        });
      }
    });
  }

  List<Map<String, dynamic>> ListNames = [
    {
      "path": "C:\\Users\\IT012.DOTCOM\\Documents",
      "count": 124,
      "size": "1.2 GB"
    },
    {
      "path": "C:\\Users\\IT012.DOTCOM\\Downloads",
      "count": 45,
      "size": "500 MB"
    },
    {
      "path": "C:\\Users\\IT012.DOTCOM\\Pictures",
      "count": 890,
      "size": "2.4 GB"
    },
    {"path": "C:\\Users\\IT012.DOTCOM\\Videos", "count": 12, "size": "6.1 GB"},
    {"path": "C:\\Users\\IT012.DOTCOM\\Desktop", "count": 12, "size": "4.1 GB"},
    {"path": "C:\\Users\\IT012.DOTCOM\\Music", "count": 12, "size": "8.1 GB"},
  ];

  String _driveSpace = "Check Drive Space"; // Initial text
  bool _isLoading = false; // Optional: use this for a spinner

  Future<void> getDiskSpace() async {
    setState(() {
      _driveSpace = "Scanning System...";
      _isLoading = true;
      ListNames = []; // Clear old data while scanning
    });

    try {
      // 1. Get Drive Space (Fast)
      var result = await Process.run('powershell', [
        '-Command',
        "Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\" | Select-Object @{n='Total';e={'{0:N2}' -f (\$_.Size / 1GB)}}, @{n='Free';e={'{0:N2}' -f (\$_.FreeSpace / 1GB)}} | ConvertTo-Json"
      ]);

      List<String> targetPaths = [
        "C:\\Users\\IT012.DOTCOM\\Documents",
        "C:\\Users\\IT012.DOTCOM\\Downloads",
        "C:\\Users\\IT012.DOTCOM\\Pictures",
        "C:\\Users\\IT012.DOTCOM\\Videos",
        "C:\\Users\\IT012.DOTCOM\\Desktop",
        "C:\\Users\\IT012.DOTCOM\\Music",
      ];

      List<Map<String, dynamic>> tempResults = [];

      // 2. Scan folders one by one
      for (String path in targetPaths) {
        int fileCount = 0;
        int totalBytes = 0;

        final dir = Directory(path);
        if (await dir.exists()) {
          try {
            // Using .list() instead of .listSync() is better for big folders
            await for (var entity
                in dir.list(recursive: true, followLinks: false)) {
              if (entity is File) {
                fileCount++;
                totalBytes += await entity.length();
              }
            }
          } catch (e) {/* Skip system locked files */}
        }

        double mb = totalBytes / (1024 * 1024);
        tempResults.add({
          "path": path,
          "count": fileCount,
          "size": mb > 1024
              ? "${(mb / 1024).toStringAsFixed(2)} GB"
              : "${mb.toStringAsFixed(2)} MB",
        });

        // OPTIONAL: Update UI after each folder finishes so the user sees progress
        setState(() {
          ListNames = List.from(tempResults);
        });
      }

      if (result.exitCode == 0) {
        var data = jsonDecode(result.stdout);
        setState(() {
          _driveSpace = "Total: ${data['Total']} GB | Free: ${data['Free']} GB";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _driveSpace = "Scan failed";
        _isLoading = false;
      });
    }
  }

  Future<void> updateNames(String mainPath) async {
    try {
      var myDir = Directory(mainPath);

      if (await myDir.exists()) {
        // 1. Get ONLY the top-level folders (recursive: false is default)
        List<FileSystemEntity> entities =
            await myDir.list(recursive: false).toList();

        List<Map<String, dynamic>> folderData = [];

        for (var entity in entities) {
          if (entity is Directory) {
            int fileCount = 0;
            int totalBytes = 0;

            try {
              // 2. ONLY count files directly inside this folder
              // We do NOT use recursive: true here.
              var subEntities = entity.listSync(recursive: false);

              for (var sub in subEntities) {
                if (sub is File) {
                  fileCount++;
                  totalBytes += sub.lengthSync();
                }
              }
            } catch (e) {
              // Skip folders with restricted access (like System Volume Information)
            }

            folderData.add({
              "path": entity.path,
              "count": fileCount,
              "size": totalBytes > (1024 * 1024 * 1024)
                  ? "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB"
                  : "${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB",
            });
          }
        }

        setState(() {
          ListNames = folderData.isEmpty
              ? [
                  {"path": "Empty", "count": 0, "size": "0 MB"}
                ]
              : folderData;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Row(children: [
            Image.asset(
              "assets/logo.png",
              fit: BoxFit.cover,
              width: 120.0,
              height: 50.0,
            ),
            // Text(widget.title),
            Text("  "),
            btn_(context),
            Spacer(),
            text_(context, Icons.add_alert, 'Notifications'),
            text_(context, Icons.verified_user, 'Profile'),
            Icon(Icons.do_disturb_on),
            Icon(Icons.cancel)
          ]),
        ),
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/back4.gif"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(children: [
              Text(""),
              Spacer(),
              header(context),
              Text(""),
              Row(
                children: [
                  // Your existing charts or buttons...
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.refresh,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),

                  ElevatedButton(
                      onPressed: getDiskSpace,
                      child: Text(
                        "C:\\ : $_driveSpace",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(231, 234, 188, 225)),
                      )),
                  Spacer()
                ],
              ),
              Container(
                  width: 500, // Set the width of the container
                  height: 450, // Set the height of the container
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Color.fromARGB(255, 117, 115, 115)),
                    // Icon(Icons.accessible, color: Colors.white),
                    color: Color.fromARGB(
                        231, 234, 188, 225), // Set the background color
                    borderRadius: BorderRadius.circular(
                        20.0), // Set the border radius to make corners rounded
                  ),
                  child: Column(children: [
                    Expanded(
                      // <--- WRAP YOUR LIST IN THIS
                      child: ListView.builder(
                        itemCount: ListNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Row(children: [
                            Text(
                              ListNames[index].length >= 30
                                  ? ListNames[index]['path'].substring(
                                      22, 30) // Starts at 15, ends at 60
                                  : ListNames[index]['path'].length > 22
                                      ? ListNames[index]['path'].substring(
                                          22) // If shorter than 60, just show from 15 to the end
                                      : ListNames[
                                          index], // If shorter than 15, show the whole thing
                              style: const TextStyle(color: Colors.white),
                            ),
                            Spacer(),
                            ElevatedButton(
                                onPressed: () {
                                  // updateNames(ListNames[index]['path']);
                                },
                                child: Text(
                                    " ${ListNames[index]['count']} Files")),
                            Text(" "),
                            ElevatedButton(
                                onPressed: () {
                                  // updateNames(ListNames[index]['path']);
                                },
                                child: Text(" ${ListNames[index]['size']} ")),
                            Text(" "),
                            ElevatedButton(
                                onPressed: () {
                                  updateNames(ListNames[index]['path']);
                                },
                                child: Icon(Icons.arrow_forward, size: 15))
                          ]));
                        },
                      ),
                    ),
                  ])),
              // cont0(context, ListNames, updateNames()),
              Text(""),
              Spacer(),
              // Container(
              //     height: 100,
              //     child: Center(
              //       child: FutureBuilder<String>(
              //         future: queryScheduledTasks(),
              //         builder: (context, snapshot) {
              //           if (snapshot.connectionState ==
              //               ConnectionState.waiting) {
              //             return CircularProgressIndicator();
              //           } else if (snapshot.hasError) {
              //             return Text('Error: ${snapshot.error}',
              //                 style: TextStyle(
              //                   fontSize: 15.0,
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.bold,
              //                 ));
              //           } else {
              //             return Text('Scheduled Tasks:\n${snapshot.data}',
              //                 style: TextStyle(
              //                   fontSize: 15.0,
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.bold,
              //                 ));
              //           }
              //         },
              //       ),
              //     )),
              // Text(
              //   ' Test: ${tasks.toString()}',
              //   style: TextStyle(
              //     fontSize: 15.0,
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.left,
              // ),
              // Container(
              //     height: 100,
              //     child: FutureBuilder<List<String>>(
              //       future: getStartupFiles(),
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return CircularProgressIndicator();
              //         } else if (snapshot.hasError) {
              //           return Text('Error: ${snapshot.error}',
              //               style: TextStyle(
              //                 fontSize: 15.0,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ));
              //         } else if (snapshot.hasData) {
              //           return ListView(
              //             children: snapshot.data!
              //                 .map((file) => ListTile(
              //                     title: Text(file,
              //                         style: TextStyle(
              //                           fontSize: 15.0,
              //                           color: Colors.white,
              //                           fontWeight: FontWeight.bold,
              //                         ))))
              //                 .toList(),
              //           );
              //         } else {
              //           return Text('No startup files found.',
              //               style: TextStyle(
              //                 fontSize: 15.0,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ));
              //         }
              //       },
              //     ))
            ])),
        bottomNavigationBar: footer(context));
  }
}

Widget btn_(context) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      primary: const Color.fromARGB(255, 139, 21, 12), // background
      onPrimary: Colors.white, // foreground
    ),
    icon: Icon(
      Icons.cloud_upload,
      size: 17,
    ),
    label: const Text(
      'Upgrade',
      style: TextStyle(fontSize: 13.0, color: Colors.white),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    },
  );
}

Widget cont0(context, ListNames, updateNames) {
  return Container(
      width: 500, // Set the width of the container
      height: 450, // Set the height of the container
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
        // Icon(Icons.accessible, color: Colors.white),
        color: Color.fromARGB(231, 234, 188, 225), // Set the background color
        borderRadius: BorderRadius.circular(
            20.0), // Set the border radius to make corners rounded
      ),
      child: Column(children: [
        Expanded(
          // <--- WRAP YOUR LIST IN THIS
          child: ListView.builder(
            itemCount: ListNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Row(children: [
                Text(ListNames[index]),
                Spacer(),
                ElevatedButton(
                    onPressed: () {
                      // const updateNames();
                    },
                    child: Icon(Icons.arrow_forward, size: 15))
              ]));
            },
          ),
        ),
      ]));
}

Widget cont(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Container(
          width: 200, // Set the width of the container
          height: 150, // Set the height of the container
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
            // Icon(Icons.accessible, color: Colors.white),
            color:
                Color.fromARGB(231, 234, 188, 225), // Set the background color
            borderRadius: BorderRadius.circular(
                20.0), // Set the border radius to make corners rounded
          ),
          child: Row(children: [
            Text(" "),
            Icon(
              Icons.home,
              size: 50.0,
            ),
            Column(
              children: [
                Spacer(),
                Text(
                  ' PRIVACY',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ' Network & Firewall',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Spacer()
              ],
            )
          ])));
}

Widget cont1(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Container(
          width: 200, // Set the width of the container
          height: 150, // Set the height of the container
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
            // Icon(Icons.accessible, color: Colors.white),
            color:
                Color.fromARGB(231, 234, 188, 225), // Set the background color
            borderRadius: BorderRadius.circular(
                20.0), // Set the border radius to make corners rounded
          ),
          child: Row(children: [
            Text(" "),
            Icon(
              Icons.power_settings_new,
              size: 50.0,
            ),
            Column(
              children: [
                Spacer(),
                Text(
                  ' PRIVACY',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ' Network & Firewall',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Spacer()
              ],
            )
          ])));
}

Widget cont2(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Container(
          width: 200, // Set the width of the container
          height: 150, // Set the height of the container
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
            // Icon(Icons.accessible, color: Colors.white),
            color:
                Color.fromARGB(231, 234, 188, 225), // Set the background color
            borderRadius: BorderRadius.circular(
                20.0), // Set the border radius to make corners rounded
          ),
          child: Row(children: [
            Text(" "),
            Icon(
              Icons.donut_large,
              size: 50.0,
            ),
            Column(
              children: [
                Spacer(),
                Text(
                  ' PROTECTION',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ' Virus & Threats',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Spacer()
              ],
            )
          ])));
}

Widget cont3(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Container(
          width: 200, // Set the width of the container
          height: 150, // Set the height of the container
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
            // Icon(Icons.accessible, color: Colors.white),
            color:
                Color.fromARGB(231, 234, 188, 225), // Set the background color
            borderRadius: BorderRadius.circular(
                20.0), // Set the border radius to make corners rounded
          ),
          child: Row(children: [
            Text(" "),
            Icon(
              Icons.settings,
              size: 50.0,
            ),
            Column(
              children: [
                Spacer(),
                Text(
                  ' RESOURCES',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ' Device & Performance',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Spacer()
              ],
            )
          ])));
}

Widget cont4(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
      child: Container(
          width: 200, // Set the width of the container
          height: 150, // Set the height of the container
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
            // Icon(Icons.accessible, color: Colors.white),
            color:
                Color.fromARGB(231, 234, 188, 225), // Set the background color
            borderRadius: BorderRadius.circular(
                20.0), // Set the border radius to make corners rounded
          ),
          child: Row(children: [
            Text(" "),
            Icon(
              Icons.vpn_lock,
              size: 50.0,
            ),
            Column(
              children: [
                Spacer(),
                Text(
                  ' DATA USAGE',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  ' Apps & Web',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Spacer()
              ],
            )
          ])));
}

Widget text_(context, icon_, text_) {
  return Row(children: [
    Icon(
      icon_,
      size: 17,
    ),
    Text(
      text_,
      style: TextStyle(fontSize: 13.0, color: Colors.black),
    )
  ]);
}

Widget header(context) {
  return Row(children: [
    Spacer(),
    Icon(Icons.beenhere, size: 50.0, color: Color.fromARGB(231, 234, 188, 225)),
    Column(
      children: [
        Text(
          ' MANAGE YOUR RESOURCES ',
          style: TextStyle(
            fontSize: 24.0,
            color: Color.fromARGB(231, 234, 188, 225),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Text(
          ' Manage all your files and tasks.',
          style: TextStyle(
            fontSize: 16.0,
            color: Color.fromARGB(231, 234, 188, 225),
          ),
          textAlign: TextAlign.left,
        )
      ],
    ),
    Column(
      children: [btn1(context), btn2(context)],
    ),
    Spacer()
  ]);
}

Widget btn1(context) {
  return Container(
      width: 85, // Set the width of the container
      height: 25, // Set the height of the container
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
        // Icon(Icons.accessible, color: Colors.white),
        color: Color.fromARGB(231, 234, 188, 225), // Set the background color
        borderRadius: BorderRadius.circular(
            5.0), // Set the border radius to make corners rounded
      ),
      child: Row(
        children: [
          Icon(Icons.power_settings_new, size: 15.0),
          Text(" "),
          Text("Permissions",
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ))
        ],
      ));
}

Widget btn2(context) {
  return Container(
      width: 85, // Set the width of the container
      height: 25, // Set the height of the container
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 117, 115, 115)),
        // Icon(Icons.accessible, color: Colors.white),
        color: Color.fromARGB(231, 234, 188, 225), // Set the background color
        borderRadius: BorderRadius.circular(
            5.0), // Set the border radius to make corners rounded
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done, size: 15.0),
          Text(" "),
          Text("Support",
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ))
        ],
      ));
}

Widget footer(context) {
  return BottomAppBar(
    color: Color.fromARGB(231, 234, 188, 225),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: Icon(Icons.power_settings_new, color: Colors.black),
            label: Text("Privacy",
                style: TextStyle(fontSize: 13.0, color: Colors.black)),
            onPressed: () {
              // Handle home button press
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.donut_large, color: Colors.black),
            label: Text("Protection",
                style: TextStyle(fontSize: 13.0, color: Colors.black)),
            onPressed: () {
              // Handle home button press
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.settings, color: Colors.black),
            label: Text("Resources",
                style: TextStyle(fontSize: 13.0, color: Colors.black)),
            onPressed: () {
              // Handle home button press
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.vpn_lock, color: Colors.black),
            label: Text("Data",
                style: TextStyle(fontSize: 13.0, color: Colors.black)),
            onPressed: () {
              // Handle home button press
            },
          ),
        ],
      ),
    ),
  );
}


// https://www.fluttericon.com/