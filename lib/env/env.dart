import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SECRET_KEY', obfuscate: true)
  static final String secretKey = _Env.secretKey;
}
