import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;
  final String serverUrl = 'http://localhost:5000';

  void connect(String userId) {
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to server');
      socket.emit('join', userId);
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });

    socket.on('newJob', (data) {
      print('New job received: $data');
      // Handle new job notification
    });

    socket.on('jobAccepted', (data) {
      print('Job accepted: $data');
      // Handle job accepted notification
    });

    socket.on('jobCompleted', (data) {
      print('Job completed: $data');
      // Handle job completed notification
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }
}