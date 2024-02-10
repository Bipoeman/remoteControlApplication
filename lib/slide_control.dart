import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PresentControl extends StatefulWidget {
  const PresentControl(
      {super.key, required this.title, required this.mqttClient});
  final String title;
  final MqttServerClient mqttClient;

  @override
  State<PresentControl> createState() => _PresentControlState();
}

class _PresentControlState extends State<PresentControl> {
  late final mqttClient = widget.mqttClient;

  MqttClientPayloadBuilder messageByteArray(String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    return builder;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                          "/presentControl/presentControl/present",
                          MqttQos.exactlyOnce,
                          messageByteArray("Exit").payload!);
                    },
                    child: const Icon(
                      Icons.exit_to_app_outlined,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      mqttClient.publishMessage(
                          "/presentControl/presentControl/present",
                          MqttQos.exactlyOnce,
                          messageByteArray("Show").payload!);
                    },
                    child: const Icon(
                      Icons.play_arrow,
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
                          "/presentControl/presentControl/slide",
                          MqttQos.exactlyOnce,
                          messageByteArray("Previous").payload!);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 65,
                    )),
                ElevatedButton(
                  onPressed: () {
                    mqttClient.publishMessage(
                        "/presentControl/presentControl/slide",
                        MqttQos.exactlyOnce,
                        messageByteArray("Next").payload!);
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 65,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The subscribed callback
void onSubscribed(String topic) {
  print('PresentationControl Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print(
      'PresentationControl OnDisconnected client callback - Client disconnection');
}
