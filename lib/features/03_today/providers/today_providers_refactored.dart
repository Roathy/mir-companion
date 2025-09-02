import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/authenticated_http_service.dart';
import '../../../network/api_endpoints.dart';
import '../models/student_today_model.dart';

/// Refactored provider that uses authenticated HTTP service
/// 
/// This demonstrates how features should access API endpoints using
/// the unified authentication approach.
final studentTodayRefactoredProvider = 
    FutureProvider.autoDispose<StudentTodayModel?>((ref) async {
  try {
    final httpService = ref.read(authenticatedHttpServiceProvider);
    
    // Check if user is authenticated first
    final isAuthenticated = await httpService.isAuthenticated();
    if (!isAuthenticated) {
      return null;
    }

    // Make authenticated request
    final response = await httpService.get(ApiEndpoints.studentsProfile);
    
    // Parse response
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'];
      if (data != null) {
        return StudentTodayModel.fromJson(data);
      }
    }
    
    return null;
  } catch (e) {
    // Log error and return null
    print('Error fetching student today data: $e');
    return null;
  }
});

/// Provider for student profile data using authenticated service
final studentProfileProvider = 
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    final httpService = ref.read(authenticatedHttpServiceProvider);
    
    final response = await httpService.get(ApiEndpoints.studentsProfile);
    
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    
    return null;
  } catch (e) {
    print('Error fetching student profile: $e');
    return null;
  }
});

/// Provider for checking authentication status
final authStatusProvider = FutureProvider<bool>((ref) async {
  final httpService = ref.read(authenticatedHttpServiceProvider);
  return await httpService.isAuthenticated();
});