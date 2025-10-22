import 'user.dart';

typedef TokensPair = ({String accessToken, String refreshToken});

typedef AuthResult<T extends User> = ({String phoneNumber, TokensPair tokens, T? account});
