class HydroPowerSite {
  final String name;
  final double hydraulicHead; // in meters
  final double penstockLength; // in meters
  final double diversionCanalLength; // in meters
  final double hydraulicFlowRate; // in cms (cubic meters per second)
  final double hydroPowerCapacity; // in kW
  final double latitude;
  final double longitude;

  HydroPowerSite({
    required this.name,
    required this.hydraulicHead,
    required this.penstockLength,
    required this.diversionCanalLength,
    required this.hydraulicFlowRate,
    required this.hydroPowerCapacity,
    required this.latitude,
    required this.longitude,
  });
}
