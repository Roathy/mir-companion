import 'package:flutter/material.dart';

import '../../../shared/services/authenticated_http_service.dart';
import '../../../network/api_endpoints.dart';

/// Refactored activity repository using the unified authentication system
class ActivityRepositoryRefactored {
  final AuthenticatedHttpService httpService;

  ActivityRepositoryRefactored({required this.httpService});

  Future<Map<String, dynamic>> fetchUnitActivity(String activityQuery) async {
    try {
      // Check if user is authenticated first
      final isAuthenticated = await httpService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': {
            'code': 401,
            'message': 'Authentication required. Please log in again.'
          }
        };
      }

      // Make authenticated request using the http service
      final response = await httpService.get('${ApiEndpoints.studentsEgp}$activityQuery');

      return response.data;
    } catch (e) {
      debugPrint('Error fetching unit activity: $e');
      
      return {
        'success': false,
        'error': {
          'code': 500,
          'message': 'Something went wrong. Please try again later.'
        }
      };
    }
  }

  Future<Map<String, dynamic>> buyExtraAttempt(int activityId) async {
    try {
      debugPrint("Attempting to buy extra attempt for activity ID: $activityId");

      // Check if user is authenticated first
      final isAuthenticated = await httpService.isAuthenticated();
      if (!isAuthenticated) {
        return {'error': 'Authentication required. Please log in again.'};
      }

      final requestData = {"id_actividad": activityId};

      debugPrint("Request data: $requestData");

      // Make authenticated request
      final response = await httpService.post(
        '/students/egp/extra-attempt',
        data: requestData,
      );

      debugPrint("Response received: ${response.data}");

      if (response.data["success"] == true) {
        debugPrint("Extra attempt purchased successfully");
        return response.data;
      } else {
        return {
          'error': response.data['error']?['message'] ?? 'Unknown error occurred'
        };
      }
    } catch (e) {
      debugPrint("Error buying extra attempt: $e");
      return {'error': 'Something went wrong. Please try again later.'};
    }
  }
}