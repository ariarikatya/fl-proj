abstract class Env {
  static const mapkitApiKey = String.fromEnvironment('MAPKIT_API_KEY');

  static const appMetricaApiKey = String.fromEnvironment('APP_METRICA_API_KEY');

  static const devMode = bool.fromEnvironment('DEV_MODE');

  static Map<String, String>? get values => devMode
      ? {'MAPKIT_API_KEY': mapkitApiKey, 'APP_METRICA_API_KEY': appMetricaApiKey, 'DEV_MODE': devMode.toString()}
      : null;
}
