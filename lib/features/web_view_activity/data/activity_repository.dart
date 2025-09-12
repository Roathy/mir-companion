import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/utils.dart';
import '../../../network/api_endpoints.dart';

class ActivityRepository {
  final Dio dio;
  final String authToken;

  ActivityRepository({required this.dio, required this.authToken});

  Future<Map<String, dynamic>> fetchUnitActivity(String activityQuery) async {
    try {
      if (authToken.isEmpty) {
        return {
          'success': false,
          'error': {
            'code': 401,
            'message': 'Authentication required. Please log in again.'
          }
        };
      }

      String fullUrl =
          "${ApiEndpoints.baseURL}${ApiEndpoints.studentsEgp}$activityQuery";
      final response = await dio.get(fullUrl,
          options: Options(headers: {
            "X-Requested-With": "XMLHttpRequest",
            "X-App-MirHorizon": createMD5Hash(),
            // "X-App-MirHorizon-NoCache": 1,
            "Authorization": "Bearer $authToken",
          }));

      return response.data;
    } on DioException catch (e) {
      debugPrint('Network error: ${e.message}');
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      // Extract error details from the response
      final errorResponse = e.response?.data;
      if (errorResponse is Map<String, dynamic> &&
          errorResponse.containsKey('error')) {
        return errorResponse; // Return the full server response as-is
      }

      return {
        'success': false,
        'error': {
          'code': e.response?.statusCode ?? 500,
          'message': 'Network issue. Please check your connection.'
        }
      };
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');

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
      debugPrint(
          "Attempting to buy extra attempt for activity ID: $activityId");

      if (authToken.isEmpty) {
        return {'error': 'Authentication required. Please log in again.'};
      }

      String fullUrl =
          "https://api.mironline.io/api/v1/students/egp/extra-attempt";
      final requestData = {"id_actividad": activityId};

      debugPrint("Sending request to: $fullUrl");
      debugPrint("Request data: $requestData");

      final response = await dio.post(fullUrl,
          data: requestData,
          options: Options(headers: {
            "X-Requested-With": "XMLHttpRequest",
            "X-App-MirHorizon": createMD5Hash(),
            "Authorization": "Bearer $authToken"
          }));

      debugPrint("Response received: ${response.data}");

      if (response.data["success"] == true) {
        debugPrint("Extra attempt purchased successfully");
        return response.data; // Return actual success response
      } else {
        return {
          'error':
              response.data['error']?['message'] ?? 'Unknown error occurred'
        };
      }
    } on DioException catch (e) {
      debugPrint('Network error: ${e.response?.data ?? e.message}');

      // Extract the error message if it's structured
      if (e.response?.data is Map<String, dynamic> &&
          e.response?.data.containsKey('error')) {
        return {
          'error': e.response?.data['error']['message'] ?? 'Unknown error'
        };
      }

      return {'error': 'Network issue. Please check your connection.'};
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return {'error': 'Something went wrong. Please try again later.'};
    }
  }
}
