import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/auth_services.dart';
import 'package:quizhoot/services/base_service.dart';

class NotificationService extends BaseService {
  static final NotificationService _instance = NotificationService._internal();

  // Private constructor
  NotificationService._internal();

  // Static getter for the singleton instance
  static NotificationService get instance => _instance;
  List<Map<String, dynamic>> notifications = [];

  // Create a notification for a classroom
  Future<http.Response> createNotification(int classroomID, String message) async {
    final response = await http.post(
      Uri.parse(getLink('create-notification')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
      body: jsonEncode({
        'classroom_id': classroomID,
        'message': message,
      }),
    );

    return response;
  }

  // Fetch notifications for a specific classroom
  Future<http.Response> fetchNotifications(int classroomID) async {
    final response = await http.get(
      Uri.parse(getLink('list-notifications', {'<int:classroom_id>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
    );
    return response;
  }

  // Delete a specific notification
  Future<http.Response> deleteNotification(int notificationID) async {
    final response = await http.delete(
      Uri.parse(getLink('delete-notification', {'<int:pk>': '$notificationID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
    );
    return response;
  }

  Future<http.Response> fetchUserNotifications() async {
    final response = await http.get(
      Uri.parse(getLink('list-user-notification')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
    );
    return response;
  }

  Future<http.Response> deleteUserNotification(int notificationID) async {
    final response = await http.delete(
      Uri.parse(getLink('remove-user-from-notification', {'<int:notification_id>': '$notificationID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
    );
    return response;
  }

}
