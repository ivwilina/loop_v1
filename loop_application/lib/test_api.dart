import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script để kiểm tra API statistics
void main() async {
  const String projectId = 'your-project-id-here'; // Thay bằng project ID thực tế
  const String token = 'your-token-here'; // Thay bằng token thực tế
  const String baseUrl = 'http://localhost:3000'; // URL server của bạn

  try {
    print('Testing task statistics API...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/task/statistics/$projectId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Successfully parsed data:');
      print('- Total tasks: ${data['totalTasks']}');
      print('- Member stats: ${data['memberStats']}');
      
      if (data['memberStats'] != null) {
        final memberStats = List<Map<String, dynamic>>.from(data['memberStats']);
        print('- Number of members with tasks: ${memberStats.length}');
        
        for (var member in memberStats) {
          print('  - ${member['fullName']}: ${member['completedTasks']}/${member['totalTasks']} tasks');
        }
      } else {
        print('- No member stats found');
      }
    } else {
      print('API call failed with status: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}
