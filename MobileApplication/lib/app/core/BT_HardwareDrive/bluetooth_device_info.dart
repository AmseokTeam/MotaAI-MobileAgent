// 文件作用：定义底层蓝牙扫描返回的设备信息和扫描结果数据结构。

class BtDeviceInfo {
  const BtDeviceInfo({
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

class BtResult {
  const BtResult({
    required this.devices,
    required this.message,
  });

  final List<BtDeviceInfo> devices;
  final String message;
}
