import 'package:health/health.dart';
import 'package:smartvillage/API/health/health_manager_ios.dart';

//902212500904-04qf2106is9r9ii1bb0ej7bjl7fhbpth.apps.googleusercontent.com

class HealthManagerAndroid extends HealthManagerIOS {

  HealthManagerAndroid() {
    healthTypes = List<HealthDataType>.from([
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.WEIGHT,
      //HealthDataType.ELECTROCARDIOGRAM,
    ]);

    //Richiedo uso Health
    health.configure();
  }

  @override
  Future<void> readECG(String cf) async {
    print("ECG not currently available");
  }
}