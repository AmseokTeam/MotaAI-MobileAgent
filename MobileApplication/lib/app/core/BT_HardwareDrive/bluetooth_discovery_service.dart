// 文件作用：封装蓝牙扫描服务边界；
import 'bluetooth_device_info.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtDiscoveryService
{
  const BtDiscoveryService();

  Future<BtResult> scanNearbyDevices() async
  {
    final devices = <BtDeviceInfo>[];
    final subscription = FlutterBluePlus.onScanResults.listen((results)
      {
      for (final result in results)
      {
        final device = result.device;
        final name = device.platformName;
        if (name.isEmpty)
        {
          continue;
        }

        devices.add
        (
          BtDeviceInfo
          (
            name:name,
            address:device.remoteId.str,
            signal: '${result.rssi} dBm',
            paired:false,
          ),
        );
      }
    }
   );

    await FlutterBluePlus.startScan
    (
      timeout:const Duration(seconds:5),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    return BtResult
    (
      devices: devices,
      message: '扫描完成，一共发现了${devices.length} 只可爱的小Mota',
    );
  }
}
