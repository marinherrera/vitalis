/// Uma leitura enviada pelo biossensor (ESP32 + DS18B20).
class SensorReading {
  const SensorReading({
    required this.timestamp,
    required this.skinTemperature,
    required this.batteryLevel,
  });

  final DateTime timestamp;

  /// Temperatura da pele na parte interna do pulso, em °C.
  final double skinTemperature;

  /// Bateria do sensor, de 0 a 100.
  final int batteryLevel;
}
