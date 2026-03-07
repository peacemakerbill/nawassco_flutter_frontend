import '../../models/water_source_model.dart';

class WaterSourceConstants {
  static const List<String> contaminationRisks = [
    'Bacterial Contamination',
    'Chemical Runoff',
    'Agricultural Pesticides',
    'Industrial Waste',
    'Sedimentation',
    'Algal Blooms',
    'Heavy Metals',
    'Nitrate Contamination',
  ];

  static const List<String> monitoringParameters = [
    'pH Level',
    'Turbidity',
    'Chlorine Residual',
    'Temperature',
    'Conductivity',
    'Dissolved Oxygen',
    'Total Coliform',
    'E. Coli',
    'Total Dissolved Solids',
    'Hardness',
  ];

  static const Map<WaterSourceType, String> sourceTypeDescriptions = {
    WaterSourceType.BOREHOLE: 'Deep well drilled into underground aquifers',
    WaterSourceType.SURFACE_WATER: 'Water from rivers, streams, and lakes',
    WaterSourceType.DAM: 'Large water storage reservoirs',
    WaterSourceType.SPRING: 'Natural groundwater discharge points',
    WaterSourceType.LAKE: 'Natural or artificial lake water sources',
    WaterSourceType.RIVER: 'Flowing river water sources',
    WaterSourceType.WELL: 'Traditional shallow well water sources',
  };

  static const Map<String, String> powerSupplyTypes = {
    'grid': 'Grid Power',
    'generator': 'Generator',
    'solar': 'Solar Power',
    'hybrid': 'Hybrid System',
  };

  static const Map<String, String> monitoringFrequencies = {
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
  };
}
