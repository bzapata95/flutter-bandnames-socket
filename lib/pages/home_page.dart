import 'dart:io';
import 'dart:math' as math;

import 'package:brand_names/services/socket_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:brand_names/models/band.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _onActiveBands);
    super.initState();
  }

  _onActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
          title:
              const Text('BandNames', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            Container(
                margin: const EdgeInsets.only(right: 10),
                child: socketService.serverStatus == ServerStatus.online
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.offline_bolt, color: Colors.red))
          ]),
      body: Column(children: [
        _showChart(),
        Expanded(
          child: ListView.builder(
            itemCount: bands.length,
            itemBuilder: (context, index) => _brandTile(bands[index]),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), elevation: 1, onPressed: addNewBand),
    );
  }

  Widget _brandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.socket.emit('delete-band', band.id);
      },
      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Delete band', style: TextStyle(color: Colors.white)))),
      child: ListTile(
        leading: CircleAvatar(
            child: Text(band.name!.substring(0, 2)),
            backgroundColor: Colors.blue[100]),
        title: Text(band.name!),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit('vote-band', band.id);
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('New band name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text('Add'),
                      onPressed: () => addBrandToList(textController.text))
                ]);
          });
    }

    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text('New band name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBrandToList(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context))
              ]);
        });
  }

  void addBrandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('new-band', name);
      setState(() {});
    }

    Navigator.pop(context);
  }

  Widget _showChart() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      height: 200,
      child: PieChart(
        PieChartData(
            sections: bands
                .map((e) => PieChartSectionData(
                      color:
                          Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                              .withOpacity(1.0),
                      title: '${e.name}',
                      value: e.votes!.toDouble(),
                      radius: 30,
                    ))
                .toList()),
        swapAnimationDuration: Duration(milliseconds: 150), // Optional
        swapAnimationCurve: Curves.decelerate, // Optional
      ),
    );
  }
}
