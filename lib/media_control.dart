import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClientPayloadBuilder messageByteArray(String message) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(message);
  return builder;
}

class MediaControl extends StatefulWidget {
  const MediaControl(
      {super.key, required this.title, required this.mqttClient});
  final String title;
  final MqttServerClient mqttClient;

  @override
  State<MediaControl> createState() => _MediaControlState();
}

class _MediaControlState extends State<MediaControl> {
  String playingStatus = "Paused";
  String muteStatus = "false";
  String vol = "0";

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.mqttClient.updates!.listen(onMessage);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
                      widget.mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Off").payload!);
                      Future.delayed(Duration(milliseconds: 500))
                          .then((value) => setState(() {}));
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
                      widget.mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Down").payload!);
                      Future.delayed(Duration(milliseconds: 500))
                          .then((value) => setState(() {}));
                    },
                    child: const Icon(
                      Icons.volume_down,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      widget.mqttClient.publishMessage(
                          "/mediaControl/mediaControl/volume",
                          MqttQos.exactlyOnce,
                          messageByteArray("Up").payload!);
                      Future.delayed(Duration(milliseconds: 500))
                          .then((value) => setState(() {}));
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
                      widget.mqttClient.publishMessage(
                          "/mediaControl/mediaControl/play",
                          MqttQos.exactlyOnce,
                          messageByteArray("Previous").payload!);
                      Future.delayed(Duration(milliseconds: 500))
                          .then((value) => setState(() {}));
                    },
                    child: const Icon(
                      Icons.skip_previous_rounded,
                      size: 65,
                    )),
                ElevatedButton(
                    onPressed: () {
                      widget.mqttClient.publishMessage(
                          "/mediaControl/mediaControl/play",
                          MqttQos.exactlyOnce,
                          messageByteArray("Toggle").payload!);
                      Future.delayed(Duration(milliseconds: 500))
                          .then((value) => setState(() {}));
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
                    widget.mqttClient.publishMessage(
                        "/mediaControl/mediaControl/play",
                        MqttQos.exactlyOnce,
                        messageByteArray("Next").payload!);
                    Future.delayed(Duration(milliseconds: 500))
                        .then((value) => setState(() {}));
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
        onPressed: () {},
        child: Text(
          vol,
          style: TextStyle(fontSize: 20, color: Colors.deepPurple),
        ),
      ),
    );
  }
}
