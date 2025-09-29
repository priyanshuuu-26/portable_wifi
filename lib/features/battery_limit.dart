import 'package:battery_plus/battery_plus.dart';

void monitorBattery(int limit, Function onLimitReached) {
  final battery = Battery();
  battery.onBatteryStateChanged.listen((BatteryState state) async {
    final batteryLevel = await battery.batteryLevel;
    if (batteryLevel <= limit) {
      onLimitReached();
    }
  });
}