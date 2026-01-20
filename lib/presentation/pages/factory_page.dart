import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/colors.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/switch_card.dart';
import '../widgets/factory/zone_control_item.dart';

import '../../core/services/ble_service.dart';
import '../../core/protocols/ckcp_protocol.dart';
import '../../core/constants/commands.dart';
import '../widgets/factory/remote_control_card.dart';
import '../../ui/widgets/debug_console.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/localization/app_localizations.dart';

/// 工厂模式页面
class FactoryPage extends ConsumerStatefulWidget {
  final VoidCallback? onExit;

  const FactoryPage({super.key, this.onExit});

  @override
  ConsumerState<FactoryPage> createState() => _FactoryPageState();
}

class _FactoryPageState extends ConsumerState<FactoryPage> {
  final _vinController = TextEditingController();
  final _carCodeController = TextEditingController();
  final _funcCodeController = TextEditingController();

  // LED 配置状态
  final Map<int, int> _ledCounts = {
    0: 20, // 主驾
    1: 20, // 副驾
    2: 15, // 左前门
    3: 15, // 右前门
    4: 12, // 左后门
    5: 12, // 右后门
  };
  final Map<int, bool> _ledDirections = {
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
  };

  // 功能开关状态
  bool _welcomeLight = false;
  bool _doorLink = false;
  bool _speedResponse = false;
  bool _turnLink = false;
  bool _acLink = false;
  bool _crashWarning = false;

  // 音源和灵敏度
  bool _isOriginalSource = false;
  int _sensitivity = 2;

  // 配置加载状态
  bool _isLoadingConfig = true;
  StreamSubscription? _infoSubscription;

  @override
  void initState() {
    super.initState();
    _loadModuleConfig();
  }

  /// 加载模块配置
  Future<void> _loadModuleConfig() async {
    final bleService = BleService.instance;

    // 订阅配置更新
    _infoSubscription = bleService.infoUpdates.listen((_) {
      _applyModuleConfig();
    });

    // 发送查询命令
    await bleService.queryModuleConfig();

    // 延迟后检查是否已获取配置
    await Future.delayed(const Duration(milliseconds: 500));
    _applyModuleConfig();
  }

  /// 应用模块配置到 UI
  void _applyModuleConfig() {
    final bleService = BleService.instance;
    final config = bleService.moduleConfig;

    if (config != null && mounted) {
      setState(() {
        _isLoadingConfig = false;

        // 应用 LED 配置
        for (int i = 0; i < 6 && i < config.ledCounts.length; i++) {
          _ledCounts[i] = config.ledCounts[i];
          _ledDirections[i] = config.ledDirections[i];
        }

        // 应用功能开关
        _welcomeLight = config.welcomeLight;
        _doorLink = config.doorLink;
        _speedResponse = config.speedResponse;
        _turnLink = config.turnLink;
        _acLink = config.acLink;
        _crashWarning = config.crashWarning;

        // 应用音频配置
        _isOriginalSource = config.isOriginalSource;
        _sensitivity = config.sensitivity;
      });
    } else if (mounted) {
      setState(() => _isLoadingConfig = false);
    }
  }

  @override
  void dispose() {
    _infoSubscription?.cancel();
    _vinController.dispose();
    _carCodeController.dispose();
    _funcCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(i18n.get('factory_mode')),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : (widget.onExit != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onExit,
                  )
                : null), // Hide back button if not push and no exit callback
        actions: [
          TextButton.icon(
            onPressed: _exitFactoryMode,
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: Text(i18n.get('exit_factory')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildDeviceRegistrationCard(),
                const SizedBox(height: 20),
                _buildLedConfigCard(),
                const SizedBox(height: 20),
                _buildSoundSettingsCard(),
                const SizedBox(height: 20),
                _buildAdvancedFeaturesCard(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const RemoteControlCard(),
                const SizedBox(height: 20),
                _buildDangerZoneCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceRegistrationCard() {
    final i18n = AppLocalizations.of(context);
    return GlassCard(
      header: GlassCardHeader(
        title: i18n.get('device_reg'),
        icon: '📋',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIN 码
          Text(
            i18n.get('vin_code'),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _vinController,
                  maxLength: 17,
                  decoration: InputDecoration(
                    hintText: i18n.get('enter_vin'),
                    counterText: '',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _registerVin,
                child: Text(i18n.get('register')),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 车型编号和功能编号
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.get('car_code'),
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _carCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: i18n.get('code_range'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _setCarCode,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(i18n.get('set')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.get('func_code'),
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _funcCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: i18n.get('code_range'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _setFuncCode,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(i18n.get('set')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedConfigCard() {
    final i18n = AppLocalizations.of(context);
    return GlassCard(
      header: GlassCardHeader(
        title: i18n.get('led_config'),
        icon: '💡',
      ),
      child: Column(
        children: [
          // 顶部指示条
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧 - 驾驶侧
              Expanded(
                child: Column(
                  children: [
                    _buildSectionHeader(i18n.get('driver_side'),
                        Icons.airline_seat_recline_normal),
                    const SizedBox(height: 16),
                    _buildZoneControlItem(0, i18n.get('main_driver')),
                    const SizedBox(height: 12),
                    _buildZoneControlItem(2, i18n.get('left_front')),
                    const SizedBox(height: 12),
                    _buildZoneControlItem(4, i18n.get('left_rear')),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // 中间分割线
              Container(
                width: 1,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).dividerColor.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 右侧 - 副驾侧
              Expanded(
                child: Column(
                  children: [
                    _buildSectionHeader(i18n.get('passenger_side'),
                        Icons.airline_seat_recline_extra),
                    const SizedBox(height: 16),
                    _buildZoneControlItem(1, i18n.get('co_pilot')),
                    const SizedBox(height: 12),
                    _buildZoneControlItem(3, i18n.get('right_front')),
                    const SizedBox(height: 12),
                    _buildZoneControlItem(5, i18n.get('right_rear')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneControlItem(int index, String label) {
    return ZoneControlItem(
      label: label,
      count: _ledCounts[index] ?? 20,
      direction: _ledDirections[index] ?? true,
      onCountChanged: (val) {
        setState(() => _ledCounts[index] = val);
        _sendLedCount(index);
      },
      onDirectionChanged: (val) {
        setState(() => _ledDirections[index] = val);
        _sendLedDirection(index);
      },
    );
  }

  Widget _buildSoundSettingsCard() {
    final i18n = AppLocalizations.of(context);
    return GlassCard(
      header: GlassCardHeader(
        title: i18n.get('sound_source'),
        icon: '🎵',
      ),
      child: Column(
        children: [
          // 音源选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildRadioCard(
                    i18n.get('builtin_mic'),
                    !_isOriginalSource,
                    () {
                      setState(() => _isOriginalSource = false);
                      _sendAudioSource();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRadioCard(
                    i18n.get('car_speaker'),
                    _isOriginalSource,
                    () {
                      setState(() => _isOriginalSource = true);
                      _sendAudioSource();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 灵敏度
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              i18n.get('rhythm_sensitivity'),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = level == _sensitivity;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _sensitivity = level);
                      _sendSensitivity();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        i18n.get('level_$level'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioCard(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFeaturesCard() {
    final i18n = AppLocalizations.of(context);
    return GlassCard(
      header: GlassCardHeader(
        title: i18n.get('advanced_features'),
        icon: '⚙️',
      ),
      child: Column(
        children: [
          SwitchCard(
            label: i18n.get('welcome_light'),
            icon: '🌟',
            value: _welcomeLight,
            onChanged: (v) {
              setState(() => _welcomeLight = v);
              _sendFeature(CkcpCommand.attachWelcome, v);
            },
          ),
          const SizedBox(height: 12),
          SwitchCard(
            label: i18n.get('door_link'),
            icon: '🚪',
            value: _doorLink,
            onChanged: (v) {
              setState(() => _doorLink = v);
              _sendFeature(CkcpCommand.attachDoor, v);
            },
          ),
          const SizedBox(height: 12),
          SwitchCard(
            label: i18n.get('speed_response'),
            icon: '🏎️',
            value: _speedResponse,
            onChanged: (v) {
              setState(() => _speedResponse = v);
              _sendFeature(CkcpCommand.attachSpeed, v);
            },
          ),
          const SizedBox(height: 12),
          SwitchCard(
            label: i18n.get('turn_link'),
            icon: '↪️',
            value: _turnLink,
            onChanged: (v) {
              setState(() => _turnLink = v);
              _sendFeature(CkcpCommand.attachTurn, v);
            },
          ),
          const SizedBox(height: 12),
          SwitchCard(
            label: i18n.get('ac_link'),
            icon: '❄️',
            value: _acLink,
            onChanged: (v) {
              setState(() => _acLink = v);
              _sendFeature(CkcpCommand.attachAC, v);
            },
          ),
          const SizedBox(height: 12),
          SwitchCard(
            label: i18n.get('crash_warning'),
            icon: '⚠️',
            value: _crashWarning,
            onChanged: (v) {
              setState(() => _crashWarning = v);
              _sendFeature(CkcpCommand.attachDashboard, v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    final i18n = AppLocalizations.of(context);
    return GlassCard(
      header: GlassCardHeader(
        title: i18n.get('danger_zone'),
        icon: '⚠️',
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.danger.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: AppColors.danger),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i18n.get('factory_reset'),
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i18n.get('factory_reset_desc'),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showResetConfirmDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  child: Text(i18n.get('confirm_reset')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== 命令发送方法 ==========

  Future<void> _registerVin() async {
    final vin = _vinController.text.trim().toUpperCase();
    if (vin.length != 17) {
      _showSnackBar(context.tr('factory_error_vin_length'));
      return;
    }

    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.registerVin(vin));
      _showSnackBar(context.tr('factory_vin_sent'));
    }
  }

  Future<void> _setCarCode() async {
    final code = int.tryParse(_carCodeController.text.trim());
    if (code == null || code < 0 || code > 255) {
      _showSnackBar(context.tr('factory_error_car_model_range'));
      return;
    }

    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.setCarCode(code));
      _showSnackBar(context.tr('factory_car_model_set'));
    }
  }

  Future<void> _setFuncCode() async {
    final code = int.tryParse(_funcCodeController.text.trim());
    if (code == null || code < 0 || code > 255) {
      _showSnackBar(context.tr('factory_error_func_range'));
      return;
    }

    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.setFuncCode(code));
      _showSnackBar(context.tr('factory_func_set'));
    }
  }

  Future<void> _sendLedCount(int index) async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      final zone = LedZone.allZones[index];
      await bleService.send(AmbientCommands.ledCount(
        zone.countCommand,
        _ledCounts[index]!,
      ));
    }
  }

  Future<void> _sendLedDirection(int index) async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      final zone = LedZone.allZones[index];
      await bleService.send(AmbientCommands.ledDirection(
        zone.directionCommand,
        _ledDirections[index]!,
      ));
    }
  }

  Future<void> _sendAudioSource() async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.dynamicSource(_isOriginalSource));
    }
  }

  Future<void> _sendSensitivity() async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.dynamicSensitivity(_sensitivity));
    }
  }

  Future<void> _sendFeature(int cmd, bool enabled) async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.attachment(cmd, enabled));
    }
  }

  Future<void> _exitFactoryMode() async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.factoryMode(false));
    }

    // 安全退出逻辑
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onExit != null) {
      widget.onExit!();
    }
  }

  Future<void> _showResetConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(context.tr('confirm_reset')),
        content: Text(context.tr('factory_reset_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('action_cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: Text(context.tr('confirm_reset')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetFactorySettings();
    }
  }

  Future<void> _resetFactorySettings() async {
    final bleService = BleService.instance;
    if (bleService.isConnected) {
      await bleService.send(AmbientCommands.factoryReset());
      _showSnackBar(context.tr('reset_sent'));
      // 这里的逻辑可以根据需要调整，例如退出工厂模式
      _exitFactoryMode();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
