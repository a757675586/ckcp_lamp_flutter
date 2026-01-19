import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/colors.dart';
import '../providers/ble_provider.dart';
import '../providers/light_provider.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/switch_card.dart';
import '../widgets/common/slider_control.dart';
import '../widgets/color_picker/hsl_color_picker.dart';
import '../widgets/device/device_card.dart';
import '../../core/constants/colors.dart' as preset_colors;
import '../../core/constants/commands.dart';
import '../../core/services/ble_service.dart';
import 'factory_page.dart';
import '../../core/extensions/context_extensions.dart';

/// 氛围灯控制页面
class AmbientLightPage extends ConsumerStatefulWidget {
  const AmbientLightPage({super.key});

  @override
  ConsumerState<AmbientLightPage> createState() => _AmbientLightPageState();
}

class _AmbientLightPageState extends ConsumerState<AmbientLightPage> {
  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(bleConnectionStateProvider);
    final lightState = ref.watch(lightControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧边栏
        SizedBox(
          width: 320,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 设备连接卡片
                GlassCard(
                  header: GlassCardHeader(
                    title: context.tr('device_connection'),
                    icon: '📡',
                  ),
                  child: connectionState.when(
                    data: (state) {
                      final deviceInfo =
                          ref.watch(connectedDeviceProvider).value;
                      return DeviceCard(
                        device: deviceInfo != null
                            ? BleDevice(
                                id: deviceInfo.id,
                                name: deviceInfo.name,
                                rssi: 0,
                              )
                            : null,
                        connectionState: state,
                        hwVersion: deviceInfo?.hwVersion,
                        swVersion: deviceInfo?.swVersion,
                        carModel: deviceInfo?.carModel,
                        onDisconnectPressed: () {
                          ref.read(bleControllerProvider.notifier).disconnect();
                        },
                      );
                    },
                    loading: () => const DeviceCard(),
                    error: (_, __) => const DeviceCard(),
                  ),
                ),
                const SizedBox(height: 20),

                // 灯光设置卡片
                GlassCard(
                  header: GlassCardHeader(
                    title: context.tr('light_settings'),
                    icon: '💡',
                  ),
                  child: _buildLightSettings(lightState),
                ),
              ],
            ),
          ),
        ),

        // 主内容区
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 模式切换
                _buildModeSwitch(lightState),
                const SizedBox(height: 20),

                // 根据模式显示不同面板
                if (lightState.currentMode == 0)
                  _buildSingleColorPanel(lightState)
                else if (lightState.currentMode == 1)
                  _buildMultiColorPanel(lightState)
                else
                  _buildRhythmPanel(lightState),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitch(LightState lightState) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildModeTab(0, context.tr('solid_color'), lightState.currentMode),
          _buildModeTab(1, context.tr('multi_color'), lightState.currentMode),
          _buildModeTab(2, context.tr('rhythm'), lightState.currentMode),
        ],
      ),
    );
  }

  Widget _buildModeTab(int mode, String label, int currentMode) {
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(lightControllerProvider.notifier).switchMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightSettings(LightState lightState) {
    return Column(
      children: [
        // 区域亮度开关
        SwitchCard(
          label: context.tr('zone_brightness'),
          value: lightState.isZoneMode,
          onChanged: (value) {
            ref.read(lightControllerProvider.notifier).setZoneMode(value);
          },
        ),
        const SizedBox(height: 16),

        // 亮度控制
        if (!lightState.isZoneMode)
          SliderControl(
            label: context.tr('master_brightness'),
            value: lightState.totalBrightness.toDouble(),
            max: 10,
            onChanged: (value) {
              ref
                  .read(lightControllerProvider.notifier)
                  .setTotalBrightness(value.toInt());
            },
          )
        else
          Column(
            children: [
              ZoneBrightnessControl(
                zoneName: context.tr('zone_1'),
                icon: '🚗',
                value: lightState.zone1Brightness.toDouble(),
                onChanged: (value) {
                  ref
                      .read(lightControllerProvider.notifier)
                      .setZoneBrightness(Zone.zone1, value.toInt());
                },
              ),
              const SizedBox(height: 12),
              ZoneBrightnessControl(
                zoneName: context.tr('zone_2'),
                icon: '🚙',
                value: lightState.zone2Brightness.toDouble(),
                onChanged: (value) {
                  ref
                      .read(lightControllerProvider.notifier)
                      .setZoneBrightness(Zone.zone2, value.toInt());
                },
              ),
              const SizedBox(height: 12),
              ZoneBrightnessControl(
                zoneName: context.tr('zone_3'),
                icon: '🚐',
                value: lightState.zone3Brightness.toDouble(),
                onChanged: (value) {
                  ref
                      .read(lightControllerProvider.notifier)
                      .setZoneBrightness(Zone.zone3, value.toInt());
                },
              ),
            ],
          ),

        const SizedBox(height: 20),

        // 开关控制
        Text(
          context.tr('switch_control'),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSwitchButton(context.tr('turn_off'), SwitchState.off,
                lightState.switchState),
            const SizedBox(width: 8),
            _buildSwitchButton(
                context.tr('turn_on'), SwitchState.on, lightState.switchState),
            const SizedBox(width: 8),
            _buildSwitchButton(context.tr('mode_sync'), SwitchState.followCar,
                lightState.switchState),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchButton(String label, int value, int currentValue) {
    final isSelected = value == currentValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(lightControllerProvider.notifier).setSwitchState(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleColorPanel(LightState lightState) {
    return GlassCard(
      header: GlassCardHeader(
        title: context.tr('rgb_color_control'),
        icon: '🎨',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 颜色选择器
          Text(
            context.tr('color_selection'),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          HslColorPicker(
            initialColor: lightState.currentColor,
            onColorChanged: (color) {
              ref.read(lightControllerProvider.notifier).setColor(color);
            },
          ),
          const SizedBox(height: 20),

          // 颜色预览
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: lightState.currentColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: lightState.currentColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
                      context.tr('current_color'),
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${lightState.currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(lightControllerProvider.notifier)
                      .setColor(lightState.currentColor);
                },
                child: Text(context.tr('apply_color')),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 预设颜色
          Text(
            context.tr('preset_colors'),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          PresetColorGrid(
            colors: preset_colors.PresetColors.basicColors,
            selectedColor: lightState.currentColor,
            onColorSelected: (color) {
              ref.read(lightControllerProvider.notifier).setColor(color);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiColorPanel(LightState lightState) {
    return GlassCard(
      header: GlassCardHeader(
        title: context.tr('multi_rgb_control'),
        icon: '🌈',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动态模式开关
          SwitchCard(
            label: context.tr('dynamic_mode'),
            value: lightState.isDynamic,
            onChanged: (value) {
              ref.read(lightControllerProvider.notifier).setDynamicMode(value);
            },
          ),
          const SizedBox(height: 24),

          // 预设主题
          Text(
            context.tr('preset_schemes'),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: preset_colors.PresetColors.multiColorThemes.map((theme) {
              final isSelected = theme.id == lightState.selectedTheme;
              return _buildThemeCard(theme, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(preset_colors.MultiColorTheme theme, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(lightControllerProvider.notifier).selectMultiTheme(theme.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(8),
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
        child: Column(
          children: [
            // 图片预览
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: theme.isCustom
                  ? Center(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    )
                  : Image.asset(
                      'assets/images/preset_${theme.id}.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image,
                              color: Colors.white54),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(theme.nameKey),
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRhythmPanel(LightState lightState) {
    return GlassCard(
      header: GlassCardHeader(
        title: context.tr('rhythm_mode'),
        icon: '🎵',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 律动预设
          Text(
            context.tr('rhythm_effects'),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: preset_colors.PresetColors.rhythmPresets.map((preset) {
              final isSelected = preset.id == lightState.rhythmTheme;
              return _buildRhythmPresetCard(preset, isSelected);
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRhythmPresetCard(
      preset_colors.RhythmPreset preset, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(lightControllerProvider.notifier).selectRhythmTheme(preset.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100, // Slightly wider for image
        padding: const EdgeInsets.all(8),
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
        child: Column(
          children: [
            // 使用 Rhythm Effect 图片
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/rhythm_${preset.id}.png',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.music_note, color: Colors.white24),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(preset.nameKey),
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
