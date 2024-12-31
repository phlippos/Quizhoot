import 'dart:convert';
import 'package:quizhoot/services/notification_service.dart';
import 'package:http/http.dart' as http;

class CNotification {
  int? _id;
  String? _username;
  int _classroomId;
  String _message;
  DateTime? _createdAt; // New field to store creation time
  String? _classroomName;
  NotificationService _service = NotificationService.instance;

   // Constructor
  CNotification(this._id, this._classroomId, this._message,  this._createdAt,this._username,this._classroomName);

  // Named constructor for creating a new notification
  CNotification.create(this._classroomId, this._message);

  int? get id => _id;

  String get username => _username!;

  set username(String value) {
    _username = value;
  }

  set id(int? value) {
    _id = value;
  }

  int get classroomId => _classroomId;

  set classroomId(int value) {
    _classroomId = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }


  DateTime get createdAt => _createdAt!;

  set createdAt(DateTime value) {
    _createdAt = value;
  }

  String get classroomName => _classroomName!;

  set classroomName(String value) {
    _classroomName = value;
  }

  NotificationService get service => _service;

  set service(NotificationService value) {
    _service = value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Check for same instance
    if (other is! CNotification) return false; // Check for same type

    return other._id == _id || other._message == _message;
  }

  Future<http.Response> add() async {
    final response = await _service.createNotification(_classroomId, _message);
    if (response.statusCode == 201) {
      _username = Map<String, dynamic>.from(json.decode(response.body))['username'];
      _id = Map<String, dynamic>.from(json.decode(response.body))['id'];
      _createdAt = DateTime.parse(Map<String, dynamic>.from(json.decode(response.body))['created_at']);
      return response;
    } else {
      throw Exception('Failed to create notification ${response.statusCode}');
    }
  }

  Future<bool> remove() async {
    final response = await _service.deleteNotification(_id!);
    if (response.statusCode == 204) {
      return true; // Return the successful response
    } else {
      throw Exception('Failed to delete notification. Status: ${response.statusCode}');
    }
  }

  // Method to compute the time difference between now and the created_at time
  String getTimeDifference() {
    final now = DateTime.now();
    final difference = now.difference(_createdAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

}
