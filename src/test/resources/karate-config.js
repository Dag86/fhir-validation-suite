function fn() {
  var config = {};

  // baseUrl: -DbaseUrl=https://... overrides default via Maven surefire systemPropertyVariables
  var baseUrl = karate.properties['baseUrl'];
  config.baseUrl = baseUrl || 'https://hapi.fhir.org/baseR4';

  var fhirVersion = karate.properties['fhirVersion'];
  config.fhirVersion = fhirVersion || '4.0.1';

  var authToken = karate.properties['authToken'];
  if (authToken) {
    karate.configure('headers', { 'Authorization': 'Bearer ' + authToken });
  }

  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 60000);

  karate.log('baseUrl:', config.baseUrl);
  karate.log('fhirVersion:', config.fhirVersion);

  return config;
}
