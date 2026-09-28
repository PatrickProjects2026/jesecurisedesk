import 'package:flutter/material.dart';
import 'package:jeecurisedesk/resources.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  String _pythonOutput = "Waiting for scan..."; // 1. Variable to hold output

  @override
  void initState() {
    super.initState();
    runPythonScanner(); // 2. Run the scanner as soon as the app opens
  }

  Future<void> runPythonScanner() async {
    setState(() {
      _pythonOutput = "Scanning started...";
    });

    try {
      // 1. Use runInShell: true for Windows
      var process = await Process.start(
        'python',
        ['scanner.py', 'C:/Users/IT012.DOTCOM/Documents/'],
        runInShell: true,
      );

      // 2. Capture both streams completely
      // We use .join() to wait until the script FINISHES and gives us the whole string
      final results = await process.stdout.transform(utf8.decoder).join();
      final errors = await process.stderr.transform(utf8.decoder).join();

      setState(() {
        if (errors.isNotEmpty) {
          // This will tell you exactly why Python is failing (e.g., missing imports)
          _pythonOutput = "Python Error:\n$errors";
        } else if (results.isEmpty) {
          _pythonOutput = "Scan complete: No data returned from script.";
        } else {
          _pythonOutput = results;
        }
      });
    } catch (e) {
      setState(() {
        _pythonOutput = "Failed to launch Python: $e";
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
                image: AssetImage("assets/back4.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(children: [
              // Container(
              //   padding: EdgeInsets.all(10),
              //   color: Colors.black.withOpacity(0.5),
              //   child: Text(
              //     _pythonOutput,
              //     style: TextStyle(
              //         color: Colors.greenAccent, fontFamily: 'monospace'),
              //   ),
              // ),
              Spacer(),
              header(context),
              Text(""), Text(""), Text(""), Text(""),
              Row(children: [
                Spacer(),
                cont1(context),
                cont2(context),
                Spacer()
              ]),
              Row(children: [
                Spacer(),
                cont3(context),
                cont4(context),
                Spacer()
              ]),
              Spacer()
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
          MaterialPageRoute(builder: (context) => const Resources()),
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
          ' YOU ARE PROTECTED ',
          style: TextStyle(
            fontSize: 24.0,
            color: Color.fromARGB(231, 234, 188, 225),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Text(
          ' Your system is currently safe.',
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