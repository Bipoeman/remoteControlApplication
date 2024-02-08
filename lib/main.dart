import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_control_mqtt/slide_control.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int pageIndex = 0;
  int pageCount = 2;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: pageIndex);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("Media Control Disposed");
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Volume Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (page) => setState(() => pageIndex = page),
            children: const <Widget>[
              MediaControl(title: 'Super Quick Volume Control'),
              PresentControl(title: 'Super Quick PowerPoint Control'),
            ],
          ),
          Positioned(
            bottom: 20,
            child: PageViewDotIndicator(
              currentItem: pageIndex,
              count: pageCount,
              unselectedColor: Colors.grey[400]!,
              selectedColor: Colors.grey[800]!,
            ),
          ),
        ],
      ),
    );
  }
}

class MediaControl extends StatefulWidget {
  const MediaControl({super.key, required this.title});
  final String title;

  @override
  State<MediaControl> createState() => _MediaControlState();
}

class _MediaControlState extends State<MediaControl> {
  final mqttClient = MqttServerClient('api.easyfarming.net', '');
  String playingStatus = "Paused";
  String muteStatus = "false";
  String vol = "0";

  void onConnected() {
    mqttClient.subscribe("/mediaControl/#", MqttQos.exactlyOnce);
  }

  void onMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    String topic = c[0].topic;
    String payload =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('Topic : $topic');
    print('Payload : $payload');
    if (topic == "/mediaControl/mediaStatus/volume") {
      // print(payload);
      setState(() => vol = payload.split(",")[0]);
      // print("");
    }
    if (topic == "/mediaControl/mediaStatus/status") {
      // print(payload);
      setState(() => playingStatus = payload);
      // print("");
    }
  }

  void initMQTT() async {
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.onSubscribed = onSubscribed;
    mqttClient.onConnected = onConnected;
    mqttClient.onAutoReconnect = onAutoReconnect;
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueIdQ1')
        // .withWillTopic(
        //     'willtopic') // If you set this you must set a will message
        // .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('MediaControl : Mosquitto client connecting....');
    mqttClient.connectionMessage = connMess;
    // mqttClient.autoReconnect = true;
    try {
      await mqttClient.connect();
    } on Exception catch (e) {
      mqttClient.disconnect();
    }
    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      print('MediaControl : Mosquitto client connected');
    } else {
      print(
          'MediaControl : ERROR Mosquitto client connection failed - disconnecting, state is ${mqttClient.connectionStatus!.state}');
    }
    mqttClient.updates!.listen(onMessage);
  }

  void onAutoReconnect() {
    // initMQTT();
    print('MediaControl : OnAutoReconnect client callback - Auto Reconnect');
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  MqttClientPayloadBuilder messageByteArray(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    return builder;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMQTT();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Off").payload!);
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
                      mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Down").payload!);
                    },
                    child: const Icon(
                      Icons.volume_down,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Up").payload!);
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
                      mqttClient.publishMessage(
                          "/mediaControl/mediaControl/play",
                          MqttQos.exactlyOnce,
                          messageByteArray("Previous").payload!);
                    },
                    child: const Icon(
                      Icons.skip_previous_rounded,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publishMessage(
                          "/mediaControl/mediaControl/play",
                          MqttQos.exactlyOnce,
                          messageByteArray("Toggle").payload!);
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
                    mqttClient.publishMessage("/mediaControl/mediaControl/play",
                        MqttQos.exactlyOnce, messageByteArray("Next").payload!);
                  },
                  child: const Icon(
                    Icons.skip_next_rounded,
                    size: 65,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initMQTT();
        },
        child: Text(
          vol,
          style: TextStyle(fontSize: 20, color: Colors.deepPurple),
        ),
      ),
    );
  }
}

/// The subscribed callback
void onSubscribed(String topic) {
  print('MediaControl : Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('MediaControl : OnDisconnected client callback - Client disconnection');
}
