import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dart_mqtt/dart_mqtt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Volume Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Super Quick Volume Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MqttClient mqttClient;
  String playingStatus = "Paused";
  String muteStatus = "false";
  String vol = "0";
  // void onMessage(var msg) {
  //   String data = String.fromCharCodes(msg.data);
  //   // dynamic dataJSON = jsonDecode(data);
  //   playingStatus = data;
  //   print(data);
  //   setState(() {});
  //   // print("message arrived");
  // }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    XTransportTcpClient transport =
        XTransportTcpClient.from("api.easyfarming.net", 1883);
    mqttClient = MqttClient(transport, log: true, allowReconnect: true)
      ..withKeepalive(60)
      ..withClientID("mqttx_test");
    mqttClient.onMqttConack((msg) {
      print("onMqttConack: $msg");
      if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) {
        mqttClient.close();
        return;
      }
      mqttClient.reSub();
    });

    // mqttClient.onBeforeReconnect(() async {
    //   print("reconnecting...");
    // });
    mqttClient.start();
    mqttClient.subscribe(
      "/mediaControl/mediaStatus/status",
      onMessage: ((msg) {
        String data = String.fromCharCodes(msg.data);
        // dynamic dataJSON = jsonDecode(data);

        // print("Get data from ${msg.t}");
        print("${DateTime.now()} : ${data}");
        setState(() {
          playingStatus = data;
        });
      }),
    );
    mqttClient.subscribe(
      "/mediaControl/mediaStatus/volume",
      onMessage: ((msg) {
        String data = String.fromCharCodes(msg.data);
        List<String> dataSplit = data.split(",");

        // if (dataSplit[0].split(":") == "mute"){
        //   muteStatus = dataSplit[1];
        // }
        // if (dataSplit[0] == "vol"){
        //   vol = dataSplit[1];
        // }
        // dynamic dataJSON = jsonDecode(data);
        // playingStatus = data;
        setState(() {
          vol = dataSplit[0];
          print(vol);
          muteStatus = dataSplit[1];
        });
      }),
    );
    // mqttClient.subscribe("/mediaControl/mediaStatus/title",onMessage: onMessage)
    //   var transport = XTransportWsClient.from(
    //   "broker.emqx.io",
    //   "/mqtt",
    //   8083,
    //   log: true,
    //   protocols: ["mqtt"], // important
    // );
  }

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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publish("/mediaControl/mediaControl/volume",
                          payload: convertStringToUint8List("Off"));
                    },
                    child: muteStatus == "true"
                        ? const Icon(
                            Icons.volume_off,
                            size: 65,
                          )
                        : const Icon(
                            Icons.volume_mute,
                            size: 65,
                          )),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publish("/mediaControl/mediaControl/volume",
                          payload: convertStringToUint8List("Down"));
                    },
                    child: const Icon(
                      Icons.volume_down,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publish("/mediaControl/mediaControl/volume",
                          payload: convertStringToUint8List("Up"));
                    },
                    child: const Icon(
                      Icons.volume_up,
                      size: 65,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publish("/mediaControl/mediaControl/play",
                          payload: convertStringToUint8List("Previous")
                          // playingStatus == "Playing" ? "Pause" : "Play"),
                          // qos: MqttQos.qos2
                          );
                    },
                    child: const Icon(
                      Icons.skip_previous_rounded,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      print("Toggle Sent");
                      mqttClient.publish("/mediaControl/mediaControl/play",
                          payload: convertStringToUint8List("Toggle")
                          // playingStatus == "Playing" ? "Pause" : "Play"),
                          // qos: MqttQos.qos2
                          );
                      // setState(() {
                      //   playingStatus = "Pending";
                      // });
                    },
                    child: playingStatus == "Playing"
                        ? const Icon(
                            Icons.play_arrow_rounded,
                            size: 65,
                          )
                        : playingStatus == "Pending"
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.pause, size: 65)),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publish("/mediaControl/mediaControl/play",
                          payload: convertStringToUint8List("Next")
                          // playingStatus == "Playing" ? "Pause" : "Play"),
                          // qos: MqttQos.qos2
                          );
                    },
                    child: const Icon(
                      Icons.skip_next_rounded,
                      size: 65,
                    )),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mqttClient.publish("/mediaControl/mediaControl/",
              payload: convertStringToUint8List("abc"));
        },
        child: Text(
          vol,
          style: TextStyle(fontSize: 20, color: Colors.deepPurple),
        ),
      ),
    );
  }
}
