// ignore: depend_on_referenced_packages, library_prefixes

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  void connect(String token) {
    _socket = IO.io(
      'https://wisdom-walk-app-1.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket']) // Force WebSocket only
          .enableAutoConnect()
          .setAuth({'token': token}) // If your backend expects token via auth
          .build(),
    );

    _socket.onConnect((_) {
      print('Socket connected');
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket.onConnectError((data) {
      print('Connection Error: $data');
    });

    _socket.onError((err) {
      print('Socket Error: $err');
    });
  }

  void disconnect() {
    _socket.disconnect();
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }
}
