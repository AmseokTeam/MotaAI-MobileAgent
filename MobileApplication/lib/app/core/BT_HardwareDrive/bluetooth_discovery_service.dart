// 文件作用：封装蓝牙扫描服务边界；

import 'bluetooth_device_info.dart';

class BluetoothDiscoveryService {
  const BluetoothDiscoveryService();

  Future<BluetoothDiscoveryResult> scanNearbyDevices() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));

    const devices = [
      BluetoothDeviceInfo(
        name: 'LinBot-01',
        address: 'A4:C1:38:21:8B:01',
        signal: '-48 dBm',
        paired: true,
      ),
      BluetoothDeviceInfo(
        name: 'Robot-01',
        address: 'F0:12:9A:BC:03:7E',
        signal: '-61 dBm',
        paired: false,
      ),
      BluetoothDeviceInfo(
        name: 'DemoBot',
        address: '20:24:06:03:19:42',
        signal: '-72 dBm',
        paired: false,
      ),
    ];

    return const BluetoothDiscoveryResult(
      devices: devices,
      message: '扫描完成，共发现 3 个设备。',
    );
  }
}
