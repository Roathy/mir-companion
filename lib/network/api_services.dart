import 'package:mironline/network/api_client.dart';

class ApiService {
  final ApiClient apiClient;

  ApiService(this.apiClient);

  Future<String?> login(String email, String password) async {

    if(email.isEmpty || password.isEmpty){
      return null;
    }

  }
}

sealed class Result<S, F> {
  const Result();
}

final class Success<S, F> extends Result<S, F>{
  const Success(this.value);
  final S value;
}

final class Failure<S, F> extends Result<S, F>{
  const Failure(this.value);
  final F value;
}