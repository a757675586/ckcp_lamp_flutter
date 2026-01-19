import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_page.dart';

import '../themes/colors.dart';
import '../providers/ble_provider.dart';
import '../widgets/device/device_card.dart';
import '../../core/services/ble_service.dart';
import '../widgets/home/connection_status_bar.dart';
import 'ambient_light_page.dart';
import 'ota_page.dart';
import 'factory_page.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/constants/app_info.dart';

/// 主页
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        const AmbientLightPage(),
        FactoryPage(onExit: () => setState(() => _currentIndex = 0)),
        const OtaPage(),
      ];

  @override
  void initState() {
    super.initState();
    // 初始化 BLE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleControllerProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听 BLE 初始化
    ref.watch(bleInitializedProvider);
    final connectionState = ref.watch(bleConnectionStateProvider);
    final isConnected = connectionState.whenOrNull(
          data: (state) => state == BleConnectionState.connected,
        ) ??
        false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // 左侧导航栏 (Sidebar)
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              children: [
                // Logo 区域
                _buildSidebarHeader(),

                const SizedBox(height: 20),

                // 导航菜单
                _buildNavItem(0, Icons.light_mode_outlined, Icons.light_mode,
                    context.tr('ambient_light')),
                _buildNavItem(1, Icons.build_outlined, Icons.build,
                    context.tr('factory_mode_nav'),
                    enabled: isConnected),
                _buildNavItem(2, Icons.system_update_outlined,
                    Icons.system_update, context.tr('ota_upgrade_nav')),

                const Spacer(),

                // 底部状态区域
                _buildSidebarFooter(connectionState),
              ],
            ),
          ),

          // 右侧主内容区
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // 顶部状态栏 (显示连接状态等)
                  _buildTopBar(connectionState),

                  // 页面内容
                  Expanded(
                    child: ClipRect(
                      child: _pages[_currentIndex],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppInfo.version,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label,
      {bool enabled = true}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                setState(() => _currentIndex = index);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    right: BorderSide(color: AppColors.primary, width: 3),
                  )
                : null,
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      theme.cardColor.withOpacity(0.5)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: enabled
                    ? (isSelected
                        ? AppColors.primary
                        : theme.textTheme.bodyMedium?.color)
                    : theme.disabledColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: enabled
                      ? (isSelected
                          ? AppColors.primary
                          : theme.textTheme.bodyLarge?.color)
                      : theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(AsyncValue<BleConnectionState> connectionState) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
      child: ElevatedButton.icon(
        onPressed: _showDeviceScanner,
        icon: const Icon(Icons.bluetooth_searching, size: 20),
        label: Text(context.tr('scan_device')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: Theme.of(context).dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AsyncValue<BleConnectionState> connectionState) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Settings Button
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: Theme.of(context).iconTheme.color),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
          connectionState.when(
            data: (state) => ConnectionStatusBadge(state: state),
            loading: () => const ConnectionStatusBadge(
                state: BleConnectionState.disconnected),
            error: (_, __) => const ConnectionStatusBadge(
                state: BleConnectionState.disconnected),
          ),
        ],
      ),
    );
  }

  void _showDeviceScanner() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: DeviceScannerDialog(),
      ),
    );
  }
}

/// 设备扫描弹窗 (改为 Dialog 样式适应 PC)
class DeviceScannerDialog extends ConsumerStatefulWidget {
  const DeviceScannerDialog({super.key});

  @override
  ConsumerState<DeviceScannerDialog> createState() =>
      _DeviceScannerDialogState();
}

class _DeviceScannerDialogState extends ConsumerState<DeviceScannerDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bleControllerProvider.notifier).startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleControllerProvider);
    final connectionState = ref.watch(bleConnectionStateProvider);
    final theme = Theme.of(context);

    return Container(
      width: 500,
      height: 600,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(context.tr('connect_device'),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 扫描状态
          if (bleState.isScanning)
            const LinearProgressIndicator(backgroundColor: Colors.transparent),

          // 列表
          Expanded(
            child: bleState.scannedDevices.isEmpty
                ? _buildEmptyState(bleState.isScanning)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bleState.scannedDevices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final device = bleState.scannedDevices[index];
                      return _buildDeviceItem(device, connectionState);
                    },
                  ),
          ),

          const Divider(height: 1),

          // 底部操作
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!bleState.isScanning)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(bleControllerProvider.notifier).startScan(),
                    icon: const Icon(Icons.refresh),
                    label: Text(context.tr('action_rescan')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isScanning) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScanning ? Icons.radar : Icons.bluetooth_disabled,
            size: 64,
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning
                ? context.tr('scan_searching')
                : context.tr('scan_no_devices'),
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(
      BleDevice device, AsyncValue<BleConnectionState> connectionState) {
    final isConnecting = connectionState.whenOrNull(
          data: (state) => state == BleConnectionState.connecting,
        ) ??
        false;

    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor:
          theme.scaffoldBackgroundColor, // Distinct background for list items
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.bluetooth, color: AppColors.primary),
      ),
      title: Text(device.name,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text('ID: ${device.id}\nRSSI: ${device.rssi} dBm',
          style: theme.textTheme.bodySmall),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: isConnecting ? null : () => _connectDevice(device),
        child: isConnecting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(context.tr('action_connect')),
      ),
    );
  }

  Future<void> _connectDevice(BleDevice device) async {
    final success =
        await ref.read(bleControllerProvider.notifier).connect(device);
    if (mounted && success) {
      Navigator.of(context).pop();
    }
  }
}
