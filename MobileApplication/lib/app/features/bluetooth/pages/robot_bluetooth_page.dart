// 文件作用：实现蓝牙页面、扫描弹窗、设备行和连接概览，视觉布局对应 Kotlin 的 BluetoothDevicesPage。

import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';
import '../../../core/BT_HardwareDrive/bluetooth_device_info.dart';
import '../models/companion_connect_state.dart';
import '../../../core/BT_HardwareDrive/bluetooth_discovery_service.dart';

class RobotBluetoothPage extends StatefulWidget {
  const RobotBluetoothPage({
    required this.connectState,
    required this.scanRequestId,
    required this.onScanStarted,
    required this.onDeviceConnected,
    required this.onDisconnectTap,
    this.discoveryService = const BtDiscoveryService(),
    super.key,
  });

  final CompanionConnectState connectState;
  final int scanRequestId;
  final VoidCallback onScanStarted;
  final ValueChanged<BtDeviceInfo> onDeviceConnected;
  final VoidCallback onDisconnectTap;
  final BtDiscoveryService discoveryService;

  @override
  State<RobotBluetoothPage> createState() => _RobotBluetoothPageState();
}

class _RobotBluetoothPageState extends State<RobotBluetoothPage> {
  List<BtDeviceInfo> _devices = const [];
  String _statusMessage = '点击扫描，弹窗查看周围蓝牙设备。';
  BtDeviceInfo? _selectedDevice;
  bool _showScanDialog = false;

  @override
  void initState() {
    super.initState();
    if (widget.scanRequestId > 0) {
      Future<void>.microtask(_openScannerDialog);
    }
  }

  @override
  void didUpdateWidget(covariant RobotBluetoothPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scanRequestId > 0 &&
        widget.scanRequestId != oldWidget.scanRequestId) {
      _openScannerDialog();
    }
  }

  Future<void> _openScannerDialog() async {
    setState(() => _showScanDialog = true);
    await _scanNearbyDevices();
  }

  Future<void> _scanNearbyDevices() async {
    widget.onScanStarted();
    final result = await widget.discoveryService.scanNearbyDevices();
    if (!mounted) {
      return;
    }

    setState(() {
      _devices = result.devices;
      _statusMessage = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageTitle(title: 'Bluetooth', subtitle: '周围设备'),
              const SizedBox(height: 22),
              BluetoothStatusPanel(
                connectState: widget.connectState,
                selectedDevice: _selectedDevice,
                statusMessage: _statusMessage,
                onScanTap: _openScannerDialog,
                onDisconnectTap: () {
                  setState(() => _selectedDevice = null);
                  widget.onDisconnectTap();
                },
              ),
              const SizedBox(height: 18),
              const SectionTitle('连接概览'),
              const SizedBox(height: 12),
              BluetoothOverviewGrid(
                deviceCount: _devices.length,
                selectedDevice: _selectedDevice,
                connectState: widget.connectState,
              ),
              const SizedBox(height: 18),
              const ActivityItem(
                emoji: '📡',
                title: '扫描说明',
                subtitle: '真机上会同时扫描已配对、经典蓝牙和 BLE 广播；若只出现已配对设备，请让目标设备进入配对/广播模式。',
                value: 'INFO',
              ),
            ],
          ),
        ),
        if (_showScanDialog)
          BluetoothScannerDialog(
            devices: _devices,
            statusMessage: _statusMessage,
            selectedDevice: _selectedDevice,
            onScanAgain: _openScannerDialog,
            onDismiss: () => setState(() => _showScanDialog = false),
            onDeviceTap: (device) {
              setState(() {
                _selectedDevice = device;
                _showScanDialog = false;
              });
              widget.onDeviceConnected(device);
            },
          ),
      ],
    );
  }
}

class BluetoothStatusPanel extends StatelessWidget {
  const BluetoothStatusPanel({
    required this.connectState,
    required this.selectedDevice,
    required this.statusMessage,
    required this.onScanTap,
    required this.onDisconnectTap,
    super.key,
  });

  final CompanionConnectState connectState;
  final BtDeviceInfo? selectedDevice;
  final String statusMessage;
  final VoidCallback onScanTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 7,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('设备扫描',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('当前状态：${statusText(connectState)}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: AppColors.lime.withValues(alpha: 0.34),
                      shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('📶', style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selectedDevice == null
                  ? Text(
                      statusMessage,
                      key: const ValueKey('status'),
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13, height: 1.46),
                    )
                  : SelectedDeviceSummary(
                      key: const ValueKey('device'), device: selectedDevice!),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: CompactActionButton(
                        text: '扫描蓝牙', highlighted: true, onTap: onScanTap)),
                const SizedBox(width: 10),
                SizedBox(
                    width: 110,
                    child: CompactActionButton(
                        text: '断开', danger: true, onTap: onDisconnectTap)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedDeviceSummary extends StatelessWidget {
  const SelectedDeviceSummary({
    required this.device,
    super.key,
  });

  final BtDeviceInfo device;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF4F7EC),
          borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.lime, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('✓',
                style: TextStyle(
                    color: AppColors.ink, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text('${device.address} · ${device.signal}',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BluetoothOverviewGrid extends StatelessWidget {
  const BluetoothOverviewGrid({
    required this.deviceCount,
    required this.selectedDevice,
    required this.connectState,
    super.key,
  });

  final int deviceCount;
  final BtDeviceInfo? selectedDevice;
  final CompanionConnectState connectState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: BluetoothMetricCard(
                title: '发现', value: '$deviceCount', subtitle: '设备')),
        const SizedBox(width: 12),
        Expanded(
          child: BluetoothMetricCard(
            title: '状态',
            value: statusText(connectState),
            subtitle: selectedDevice?.name ?? '未选择',
            accent: AppColors.lime,
          ),
        ),
      ],
    );
  }
}

class BluetoothMetricCard extends StatelessWidget {
  const BluetoothMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.accent = Colors.white,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(26),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: SizedBox(
        height: 118,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 25,
                      fontWeight: FontWeight.w800)),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.62),
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class BluetoothScannerDialog extends StatelessWidget {
  const BluetoothScannerDialog({
    required this.devices,
    required this.statusMessage,
    required this.selectedDevice,
    required this.onScanAgain,
    required this.onDismiss,
    required this.onDeviceTap,
    super.key,
  });

  final List<BtDeviceInfo> devices;
  final String statusMessage;
  final BtDeviceInfo? selectedDevice;
  final VoidCallback onScanAgain;
  final VoidCallback onDismiss;
  final ValueChanged<BtDeviceInfo> onDeviceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.36),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      alignment: Alignment.center,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        elevation: 18,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('选择蓝牙设备',
                            style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w800)),
                        Text(statusMessage,
                            style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                height: 1.5)),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onDismiss,
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Center(
                            child: Text('×',
                                style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CompactActionButton(
                  text: '重新扫描', highlighted: true, onTap: onScanAgain),
              const SizedBox(height: 14),
              if (devices.isEmpty)
                const EmptyBluetoothDialogState()
              else
                Column(
                  children: devices
                      .map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BluetoothDeviceRow(
                            device: device,
                            selected: selectedDevice?.address == device.address,
                            onTap: () => onDeviceTap(device),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyBluetoothDialogState extends StatelessWidget {
  const EmptyBluetoothDialogState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F2),
          borderRadius: BorderRadius.circular(24)),
      child: const Column(
        children: [
          Text('📡', style: TextStyle(fontSize: 28)),
          SizedBox(height: 6),
          Text('正在等待扫描结果',
              style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          Text('模拟器可能不会返回真实设备',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class BluetoothDeviceRow extends StatelessWidget {
  const BluetoothDeviceRow({
    required this.device,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final BtDeviceInfo device;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.lime : AppColors.cardSoft,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(selected ? '✓' : '📶',
                    style: const TextStyle(
                        color: AppColors.ink, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('${device.address} · ${device.signal}',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                selected
                    ? '已连接'
                    : device.paired
                        ? '配对'
                        : '连接',
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
