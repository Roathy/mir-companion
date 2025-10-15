import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/services/refresh_provider.dart';
import 'package:mironline/services/providers.dart';

import '../../02_auth/presentation/screens/auth_screen.dart';
import '../data/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authToken = ref.read(authTokenProvider);
  return ActivityRepository(dio: apiClient.dio, authToken: authToken);
});

final unitActivityProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, activityQuery) async {
  final repository = ref.read(activityRepositoryProvider);
  final data = await repository.fetchUnitActivity(activityQuery);

  if (data.containsKey('error')) {
    if (data['error'] is Map &&
        data['error']['message'] ==
            'You have reached the maximum number of attempts for the exercise, please return to the main menu and continue with the next activity') {
      return data;
    }
    throw Exception(
        data['error']); // Ensure the error message is shown properly
  }

  return data;
});

enum BuyAttemptState { initial, loading, success, error }

class BuyAttemptNotifier extends AsyncNotifier<BuyAttemptState> {
  String? errorMessage;

  @override
  FutureOr<BuyAttemptState> build() {
    return BuyAttemptState.initial;
  }

  Future<void> buyAttempt(int activityId) async {
    state = const AsyncValue.loading();
    errorMessage = null;

    try {
      // TODO: Add proper error handling
      // debugPrint("Starting buy attempt process for activity ID: $activityId");
      final repository = ref.read(activityRepositoryProvider);
      final result = await repository.buyExtraAttempt(activityId);

      if (result.containsKey('error')) {
        errorMessage = result['error'];
        // TODO: Add proper error handling
        // debugPrint("Buy attempt failed: $errorMessage");
        state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
      } else {
        state = const AsyncValue.data(BuyAttemptState.success);
        // TODO: Add proper error handling
        // debugPrint("Buy attempt process completed successfully");

        // Invalidate the unitActivityProvider to reload the activity
        ref.invalidate(unitActivityProvider);
        ref.read(activitiesRefreshProvider.notifier).state++;
      }
    } catch (e) {
      // TODO: Add proper error handling
      // debugPrint("Unexpected buy attempt error: $e");
      errorMessage = "An unexpected error occurred. Please try again.";
      state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
    }
  }
}

final buyAttemptNotifierProvider =
    AsyncNotifierProvider<BuyAttemptNotifier, BuyAttemptState>(
        () => BuyAttemptNotifier());
