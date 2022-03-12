import 'dart:ffi';

import 'package:brand_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    _handleEmitMessage(message) {
      socketService.socket.emit('emitir-mensaje', message);
    }

    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Server Status: ${socketService.serverStatus}')]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          final Map<String, dynamic> message = {
            'name': 'Flutter',
            'message': 'Hola desde flutter'
          };
          _handleEmitMessage(message);
        },
      ),
    );
  }
}
