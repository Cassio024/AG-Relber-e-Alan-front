// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://agenda-relber-e-alan.onrender.com/api',
  );

  static Future<Map<String, dynamic>> registerUser(String name, String email, String password, DateTime birthDate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'birthDate': birthDate.toIso8601String(),
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao registar');
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  static Future<Map<String, dynamic>> verifyIdentity(String email, DateTime birthDate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/verify-identity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'birthDate': birthDate.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(jsonDecode(response.body)['message'] ?? 'Falha na verificação');
  }

  static Future<void> resetPassword(String userId, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
    );
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao redefinir a senha');
  }

  static Future<void> deleteOwnAccount(String userId, String password) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/me/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao apagar a conta');
    }
  }

  static Future<List<dynamic>> getEvents(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/events/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  static Future<Map<String, dynamic>> createEvent(String userId, String eventName, String venue, DateTime dateTime, double value, String status, String description) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'eventName': eventName,
        'venue': venue,
        'dateTime': dateTime.toIso8601String(),
        'value': value,
        'status': status,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao criar evento');
    }
  }

  static Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/events/$eventId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao atualizar evento');
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/events/$eventId'));
    if (response.statusCode != 200) {
      throw Exception('Falha ao apagar evento');
    }
  }
}