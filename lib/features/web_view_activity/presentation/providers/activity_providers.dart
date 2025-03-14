// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../02_auth/presentation/screens/auth_screen.dart';
// import '../../data/activity_repository.dart';

// final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
//   final dio = ref.read(dioProvider);
//   final authToken = ref.read(authTokenProvider);
//   return ActivityRepository(dio: dio, authToken: authToken);
// });

// final unitActivityProvider = FutureProvider.autoDispose
//     .family<Map<String, dynamic>, String>((ref, activityQuery) async {
//   final repository = ref.read(activityRepositoryProvider);
//   return repository.fetchUnitActivity(activityQuery);
// });

// enum BuyAttemptState { initial, loading, success, error }

// final buyAttemptStateProvider = StateProvider.autoDispose<BuyAttemptState>(
//     (ref) => BuyAttemptState.initial);

// final buyAttemptProvider =
//     FutureProvider.autoDispose.family<void, int?>((ref, activityId) async {
//   final repository = ref.read(activityRepositoryProvider);
//   final stateNotifier = ref.read(buyAttemptStateProvider.notifier);

//   stateNotifier.state = BuyAttemptState.loading;
//   try {
//     await repository.buyAttempt(activityId!);
//     stateNotifier.state = BuyAttemptState.success;
//   } catch (e) {
//     debugPrint("Buy attempt error: $e");
//     stateNotifier.state = BuyAttemptState.error;
//     rethrow;
//   }
// });
