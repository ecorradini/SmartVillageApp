import 'package:health/health.dart';
import 'package:intl/intl.dart';

///Classe rappresentante una misurazione in Mosaico
class MosaicoMeasurement {
  // Attributi come il dict richiesto da Mosaico
  DateTime _date;
  DateTime get date => _date;
  double _value0;
  double? _value1;
  String _device;

  //Costruttore di default
  MosaicoMeasurement({
    required DateTime date,
    required double value0,
    double? value1,
    required String device}) : _date = date,
        _value0 = value0,
        _value1 = value1,
        _device = device;

  ///Factory Method per istanziare direttamente da HealthDataPoint di Health (value 2 non necessario)
  static MosaicoMeasurement fromHealthDataPoint(HealthDataPoint point) {
    return MosaicoMeasurement(
        date: point.dateFrom,
        value0: point.value.toJson()['numeric_value'] as double,
        device: point.sourceName
    );
  }

  ///Factory Method per istanziare da due HealthDataPoint (caso value0 e value1)
  static MosaicoMeasurement fromHealthDataPoints(HealthDataPoint point0, HealthDataPoint point1) {
    return MosaicoMeasurement(
        date: point0.dateFrom,
        value0: point0.value.toJson()['numeric_value'] as double,
        value1: point1.value.toJson()['numeric_value'] as double,
        device: point0.sourceName
    );
  }

  Map<String,dynamic> toDict() {
    return {
      "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(_date),
      "value0": _value0,
      "value1": _value1 ?? 0,
      "device": _device
    };
  }
}