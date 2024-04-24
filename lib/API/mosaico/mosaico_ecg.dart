import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:smartvillage/API/mosaico/mosaico_measurement.dart';

///Classe che rappresenta una misurazione ECG in Mosaico
class MosaicoECG extends MosaicoMeasurement {

  List<num> _values;
  DateTime _endDate;
  int _classification;
  num _averageHeartRate;
  num _frequence;

  MosaicoECG({
    required DateTime startDate,
    required List<num> values,
    required String device,
    required DateTime endDate,
    required int classification,
    required num averageHeartRate,
    required num frequence}) :
      _values = values,
      _endDate = endDate,
      _classification = classification,
      _averageHeartRate = averageHeartRate,
      _frequence = frequence,
      super(date: startDate, value0: 0, device: device);

  ///Factory Method per istanziare da HealthDataPoint di Health
  static MosaicoECG fromHealthDataPoint(HealthDataPoint point) {
    List<num> voltageValues = [];
    for (var v in (point.value as ElectrocardiogramHealthValue).voltageValues) {
      //MAX 5 numeri dopo la virgola
      voltageValues.add(num.parse(v.voltage.toStringAsFixed(5)));
    }
    return MosaicoECG(
        startDate: point.dateFrom,
        values: voltageValues,
        device: point.sourceName,
        endDate: point.dateTo,
        classification: (point.value as ElectrocardiogramHealthValue).classification?.value ?? -500,
        averageHeartRate: ((point.value as ElectrocardiogramHealthValue).averageHeartRate ?? 0),
        frequence: ((point.value as ElectrocardiogramHealthValue).samplingFrequency ?? 512));
  }

  Map<String,dynamic> toDict() {
    return {
      "startDate": DateFormat("yyyy-MM-dd HH:mm:ss").format(date),
      "endDate": DateFormat("yyyy-MM-dd HH:mm:ss").format(_endDate),
      "values": _values,
      "classification": _classification.toString(),
      "averageHR": _averageHeartRate,
      "val_qnt": _values.length.toInt(),
      "freq_hz": _frequence,
    };
  }
}