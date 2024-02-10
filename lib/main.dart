import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_control_mqtt/media_control.dart';
import 'package:media_control_mqtt/slide_control.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

MqttClientPayloadBuilder messageByteArray(String message) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(message);
  return builder;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int pageIndex = 0;
  int pageCount = 2;
  late PageController pageController;
  MqttServerClient mqttClient = MqttServerClient('api.easyfarming.net', '');

  void onConnected() {
    mqttClient.subscribe("/mediaControl/#", MqttQos.exactlyOnce);
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
    mqttClient.autoReconnect = true;
    try {
      await mqttClient.connect();
    } on Exception catch (e) {
      mqttClient.disconnect();
    }
    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      print('Main App : Mosquitto client connected');
    } else {
      print(
          'Main App : ERROR Mosquitto client connection failed - disconnecting, state is ${mqttClient.connectionStatus!.state}');
    }
  }

  void onAutoReconnect() {
    print('MediaControl : OnAutoReconnect client callback - Auto Reconnect');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMQTT();
    pageController = PageController(initialPage: pageIndex);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Volume Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (page) => pageIndex = page,
            children: <Widget>[
              MediaControl(
                  title: 'Super Quick Volume Control', mqttClient: mqttClient),
              PresentControl(
                  title: 'Super Quick Slide Control', mqttClient: mqttClient),
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

/// The subscribed callback
void onSubscribed(String topic) {
  print('MediaControl : Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('MediaControl : OnDisconnected client callback - Client disconnection');
}
