import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  ChatService() {
    connect();
  }

  void connect() {
    socket = IO.io('http://127.0.0.1:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) => print('Connected'));
    socket.on('disconnect', (_) => print('Disconnected'));

    socket.connect();
  }

  void initializeChatbot(String model, String database) {
    socket.emit(
      'initialize_chatroom',
      {
        'model': model,
        'database': database,
      },
    );
  }

  void chatWithBot(String chatroom, String query, BuildContext context) {
    socket.emit(
      'chat_with_bot',
      {
        'chatroom': chatroom,
        'query': query,
      },
    );
  }

  // No te olvides de desconectar cuando termines
  void disconnect() {
    socket.disconnect();
  }
}