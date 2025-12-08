import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/utils/crypto.dart';

import '../network/api_endpoints.dart';
import 'providers.dart';

@immutable
class UserData {
  final String fullname;
  final int mircoins;

  const UserData({required this.fullname, required this.mircoins});

  UserData copyWith({String? fullname, int? mircoins}) {
    return UserData(
      fullname: fullname ?? this.fullname,
      mircoins: mircoins ?? this.mircoins,
    );
  }
}

class UserDataNotifier extends StateNotifier<AsyncValue<UserData>> {
  final Ref ref;

  UserDataNotifier(this.ref) : super(const AsyncValue.loading()) {
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final authToken = ref.read(authTokenProvider);

      if (authToken.isEmpty) {
        state = AsyncValue.error('No auth token found', StackTrace.current);
        return;
      }

      String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsProfile}";

      Response response = await apiClient.dio.get(
        fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }),
      );

      final alumno = response.data['data']['alumno'];
      state = AsyncValue.data(UserData(
        fullname: alumno['fullname'] ?? '',
        mircoins: alumno['mircoins'] ?? 0,
      ));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void updateMircoins(int newBalance) {
    state.whenData((userData) {
      state = AsyncValue.data(userData.copyWith(mircoins: newBalance));
    });
  }

  void decrementMircoins(int amount) {
    state.whenData((userData) {
      state = AsyncValue.data(
          userData.copyWith(mircoins: userData.mircoins - amount));
    });
  }

  void refresh() {
    state = const AsyncValue.loading();
    _fetchUserData();
  }

  void clear() {
    state = const AsyncValue.loading();
  }
}

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, AsyncValue<UserData>>((ref) {
  return UserDataNotifier(ref);
});
