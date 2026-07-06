// 文件作用：封装 BLE 蓝牙扫描服务，负责发现附近设备并返回给页面展示。
import 'bluetooth_device_info.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtDiscoveryService{
  const BtDiscoveryService();

  Future<BtResult> scanNearbyDevices() async{
    final devicesById = <String,BtDeviceInfo>{};// 用设备唯一 id 保存扫描结果

    // 监听扫描结果；BLE 扫描会持续返回多批结果
    final subscription = FlutterBluePlus.onScanResults.listen((results){
      for (final result in results){
        final device = result.device;
        final name = device.platformName;
        if (name.isEmpty){
          continue;
        }

        final id = device.remoteId.str;// 获取蓝牙设备的唯一 id
        devicesById[id] = BtDeviceInfo(
          name: name,
          address: id,
          signal: '${result.rssi} dBm',
          paired:false,
        );
      }
    });

    await FlutterBluePlus.startScan(
      timeout:const Duration(seconds:5),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    await FlutterBluePlus.stopScan();// 停止蓝牙扫描
    await subscription.cancel();// 停止监听扫描结果

    final devices = devicesById.values.toList();// 将去重后的 Map 结果转换为页面需要的列表
    return BtResult(
      devices: devices,
      message: '扫描完成，一共发现了${devices.length} 只可爱的小Mota',
    );
  }
}
