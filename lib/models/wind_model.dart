class WindSite {
  final String siteNumber;
  final String coordinates;
  final double areaAcres;
  final String municipality;
  final double avgWindSpeed;
  final double avgWindDensity;

  WindSite({
    required this.siteNumber,
    required this.coordinates,
    required this.areaAcres,
    required this.municipality,
    required this.avgWindSpeed,
    required this.avgWindDensity,
  });
}

class CaseASite {
  final int siteNumber;
  final double powerDensity;
  final double bladeSweptArea;
  final double maxEfficiency;
  final int numTurbines;
  final int effectiveHours;
  final double annualEnergyYield;

  CaseASite({
    required this.siteNumber,
    required this.powerDensity,
    required this.bladeSweptArea,
    required this.maxEfficiency,
    required this.numTurbines,
    required this.effectiveHours,
    required this.annualEnergyYield,
  });
}
