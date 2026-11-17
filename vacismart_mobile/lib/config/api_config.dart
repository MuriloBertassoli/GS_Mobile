class ApiConfig {
  // Base URL padrão apontando para o host local da API J4
  // No Emulador Android, usar "adb reverse tcp:8080 tcp:8080" permite manter 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

  // Monta os cabeçalhos padrão exigidos pelo Spring Security (Bearer JWT + JSON)
  static Map<String, String> headers({String? token}) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }
}