// 文件作用：定义蓝牙设备在 UI 中展示所需的数据结构。

class BluetoothUiDevice {
  const BluetoothUiDevice({
    required this.name,
    required this.address,
    required this.signal,
    required this.paired,
  });

  final String name;
  final String address;
  final String signal;
  final bool paired;
}

class BluetoothDiscoveryResult {
  const BluetoothDiscoveryResult({
    required this.devices,
    required this.message,
  });

  final List<BluetoothUiDevice> devices;
  final String message;
}
