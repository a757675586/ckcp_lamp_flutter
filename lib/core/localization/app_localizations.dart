import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // Settings
      'settings_title': 'Settings',
      'online_upgrade': 'Online Upgrade',
      'checking_updates': 'Checking...',
      'latest_version': 'Already up to date',
      'new_version_found': 'New Version Found',
      'update_now': 'Update Now',
      'update_content': 'What\'s New:',
      'ignore': 'Ignore',
      // Upgrade Dialog
      'upgrade_title': 'Upgrade',
      'update_source': 'Source',
      'current_version': 'Current',
      'latest_version_label': 'Latest',
      'release_date': 'Date',
      'check_update': 'Check Update',
      'official_download': 'Website',
      'start_update': 'Start Update',
      'new_version_details': 'Release Notes',
      'appearance': 'Appearance',
      'theme_mode': 'Theme',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'language': 'Language',
      'lang_zh': 'Chinese',
      'lang_en': 'English',
      'about': 'About',
      'version': 'Version',

      // Device
      'no_device_selected': 'No Device',
      'connecting': 'Connecting...',
      'disconnect': 'Disconnect',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'hw_version': 'Hardware',
      'sw_version': 'Software',
      'car_model': 'Car Model',
      'please_connect': 'Please scan and connect',
      'connect_device': 'Connect Device',
      'master_brightness': 'Master Brightness',
      'switch_control': 'Switch Control',
      'turn_on': 'On',
      'turn_off': 'Off',
      'mode_sync': 'Sync',

      // OTA
      'firmware_file': 'Firmware File',
      'clear_file': 'Clear',
      'ota_upgrade': 'OTA Upgrade',
      'upgrade_notes': 'Upgrade Notes',
      'select_firmware': 'Select Firmware File',
      'supports_bin': 'Supports .bin format',
      'ready': 'Ready',
      'upgrade_success': 'Upgrade Successful!',
      'upgrade_failed': 'Upgrade Failed',
      'cancelled': 'Cancelled',
      'preparing': 'Preparing...',
      'upgrading': 'Upgrading...',
      'please_select_file': 'Please select firmware file',
      'upgrade_in_progress': 'Upgrade in progress',

      // New OTA Keys
      'ota_preparing': 'Preparing...',
      'ota_step_request': 'Sending upgrade request...',
      'ota_step_finish': 'Finishing...',
      'ota_step_finishing': 'Sending completion signal...',
      'ota_success': 'Upgrade Successful!',
      'ota_failed': 'Upgrade Failed',
      'ota_ready': 'Ready',
      'ota_cancelled': 'Cancelled',
      'ota_in_progress': 'Upgrade in progress',
      'ota_select_firmware_first': 'Please select firmware first',
      'ota_error_in_progress': 'Upgrade currently in progress',
      'ota_error_not_connected': 'Device not connected',
      'ota_error_no_ack': 'Device did not respond to request',
      'ota_error_frame_failed': 'Frame transmission failed',
      'ota_error_cancelled': 'Upgrade cancelled',
      'ota_error_no_finish_ack': 'Did not receive completion confirmation',
      'ota_error_device_rejected': 'Device rejected upgrade',
      'ota_firmware_name': 'Filename',
      'ota_file_size': 'Size',
      'ota_frame_count': 'Frames',
      'ota_status_connected': 'Device Connected',
      'ota_status_disconnected': 'Device Disconnected',
      'ota_connect_first': 'Connect device first',
      'ota_device_info': 'Device Info',
      'ota_hw_version': 'Hardware',
      'ota_sw_version': 'Software',
      'ota_car_model': 'Car Model',
      'ota_packet_count': 'OTA Packets',
      'ota_cancel': 'Cancel Upgrade',
      'ota_start': 'Start Upgrade',
      'ota_step_1': 'Select Firmware',
      'ota_step_1_desc': 'Click to select .bin file',
      'ota_step_2': 'Connect Device',
      'ota_step_2_desc': 'Ensure bluetooth is connected',
      'ota_step_3': 'Start Upgrade',
      'ota_step_3_desc': 'Do not disconnect during process',
      'ota_step_4': 'Wait Completion',
      'ota_step_4_desc': 'Device will restart automatically',
      'ota_warning':
          'Do not close app or disconnect during upgrade to avoid damage.',
      'ota_confirm_title': 'Confirm Upgrade',
      'ota_confirm_content': 'Start firmware upgrade? Do not disconnect.',

      // Factory Mode
      'factory_mode': 'Factory Mode',
      'exit_factory': 'Exit Factory Mode',
      'led_config': 'LED Configuration (Zone Settings)',
      'driver_side': 'Driver Side (Left)',
      'passenger_side': 'Passenger Side (Right)',
      'forward': 'Forward',
      'reverse': 'Reverse',
      'led_unit': 'pcs',
      'device_reg': 'Device Registration',
      'vin_code': 'VIN Code (17 characters)',
      'enter_vin': 'Enter VIN',
      'car_code': 'Car Code',
      'func_code': 'Function Code',
      'set': 'Set',
      'register': 'Register',
      'danger_zone': 'Danger Zone',
      'factory_reset': 'Factory Reset',
      'factory_reset_desc': 'This will clear all settings, irreversible',
      'confirm_reset': 'Confirm Reset',
      'cancel': 'Cancel',
      'vin_must_17': 'VIN must be 17 characters',
      'code_range': 'Range: 0-255',
      'vin_sent': 'VIN code sent',
      'code_set': 'Code set',
      'reset_sent': 'Factory reset command sent',

      // New Factory Keys
      'factory_error_vin_length': 'VIN must be 17 characters',
      'factory_vin_sent': 'VIN sent',
      'factory_error_car_model_range': 'Car Model ID must be 0-255',
      'factory_car_model_set': 'Car Model set',
      'factory_error_func_range': 'Function ID must be 0-255',
      'factory_func_set': 'Function ID set',

      // Remote Control
      'remote_control': 'Remote Control',
      'start_can': 'Start CAN',
      'start_lin': 'Start LIN',
      'stop_monitor': 'Stop',
      'save_log': 'Save Log',
      'save_success': 'Saved: ',
      'save_failed': 'Save failed: ',
      'no_data': 'No data to save',
      'select_location': 'Select save location:',
      'default_location': 'Default (Documents)',
      'choose_location': 'Choose Location...',
      'total_records': 'Total records: ',
      'started_can': 'CAN monitor started: ',
      'started_lin': 'LIN monitor started: ',
      'stopped': 'Monitor stopped',
      'seq': 'Seq',

      // Color Picker
      'hue': 'Hue',
      'saturation': 'Saturation',
      'lightness': 'Lightness',

      // Sound Settings
      'sound_source': 'Sound Source',
      'builtin_mic': 'Built-in Mic',
      'car_speaker': 'Car Speaker',
      'sensitivity': 'Sensitivity',
      'level': 'Level',

      // Advanced Features
      'advanced_features': 'Advanced Features',
      'welcome_light': 'Welcome Light',
      'door_link': 'Door Link',
      'speed_response': 'Speed Response',
      'turn_link': 'Turn Signal Link',
      'ac_link': 'AC Link',
      'crash_warning': 'Crash Warning',

      // Zones
      'main_driver': 'Main Driver',
      'co_pilot': 'Passenger',
      'left_front': 'Left Front Door',
      'right_front': 'Right Front Door',
      'left_rear': 'Left Rear Door',
      'right_rear': 'Right Rear Door',

      // Common
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'confirm': 'Confirm',
      'info': 'Info',
      'action_cancel': 'Cancel',
      'action_confirm': 'Confirm',

      // Navigation / Sidebar
      'ambient_light': 'Ambient Light',
      'factory_mode_nav': 'Factory Mode',
      'ota_upgrade_nav': 'OTA Upgrade',
      'scan_device': 'Scan Device',
      'scan_searching': 'Searching for nearby devices...',
      'scan_no_devices': 'No devices found',
      'action_connect': 'Connect',
      'action_rescan': 'Rescan',

      // Device Card
      'device_connection': 'Device Connection',
      'light_settings': 'Light Settings',
      'zone_brightness': 'Zone Brightness',
      'zone_1': 'Zone 1',
      'zone_2': 'Zone 2',
      'zone_3': 'Zone 3',
      'zone_4': 'Zone 4',
      'zone_5': 'Zone 5',
      'zone_6': 'Zone 6',

      // Color Modes
      'solid_color': 'Solid',
      'multi_color': 'Multi',
      'rhythm': 'Rhythm',

      // Solid Color Mode
      'rgb_color_control': 'RGB Color Control',
      'color_selection': 'Color Selection',
      'current_color': 'Current Color',
      'preset_colors': 'Preset Colors',
      'apply_color': 'Apply Color',

      // Multi Color Mode
      'multi_rgb_control': 'Multi RGB Control',
      'dynamic_mode': 'Dynamic Mode',
      'preset_schemes': 'Preset Schemes',
      'custom': 'Custom',
      'preset_lakeside': 'Lakeside Rain',
      'preset_lotus': 'Lotus in the Breeze',
      'preset_sunset': 'Leifeng Sunset',
      'preset_moonspring': 'Moon Spring Dawn',
      'preset_fishpond': 'Spring Shade on Jade Island',
      'preset_westlake': 'Snow on Western Hills',
      'preset_autumn': 'Autumn Moon over Calm Lake',
      'preset_bamboo': 'Bamboo-lined Path at Yunqi',
      'preset_lakeglow': 'Autumn Colors of Dongting',
      'preset_aurora': 'Infinite Gradient',

      // Rhythm Mode
      'rhythm_mode': 'Rhythm Mode',
      'rhythm_effects': 'Rhythm Effects',
      'mode_1': 'Mode 1',
      'mode_2': 'Mode 2',
      'mode_3': 'Mode 3',
      'mode_4': 'Mode 4',
      'mode_5': 'Mode 5',
      'mode_6': 'Mode 6',
      'mode_7': 'Mode 7',
      'mode_8': 'Mode 8',
      'rhythm_sensitivity': 'Sensitivity',
      'level_1': 'Lv 1',
      'level_2': 'Lv 2',
      'level_3': 'Lv 3',
      'level_4': 'Lv 4',
      'level_5': 'Lv 5',
    },
    'zh': {
      // Settings
      'settings_title': '设置',
      'online_upgrade': '在线升级',
      'checking_updates': '正在检查更新...',
      'latest_version': '当前已是最新版本',
      'new_version_found': '发现新版本',
      'update_now': '立即更新',
      'update_content': '更新内容：',
      'ignore': '忽略',
      // Upgrade Dialog
      'upgrade_title': '升级',
      'update_source': '更新源',
      'current_version': '当前版本',
      'latest_version_label': '最新版本',
      'release_date': '发行日期',
      'check_update': '检查更新',
      'official_download': '官网下载',
      'start_update': '开始更新',
      'new_version_details': '新版本详情',
      'appearance': '外观',
      'theme_mode': '主题',
      'theme_light': '浅色',
      'theme_dark': '深色',
      'theme_system': '跟随系统',
      'language': '语言',
      'lang_zh': '简体中文',
      'lang_en': 'English',
      'about': '关于',
      'version': '版本',

      // Device
      'no_device_selected': '未选择设备',
      'connecting': '连接中...',
      'disconnect': '断开连接',
      'connected': '已连接',
      'disconnected': '未连接',
      'hw_version': '硬件版本',
      'sw_version': '软件版本',
      'car_model': '车型代码',
      'please_connect': '请扫描并连接设备',
      'connect_device': '连接设备',
      'master_brightness': '总亮度',
      'switch_control': '开关控制',
      'turn_on': '打开',
      'turn_off': '关闭',
      'mode_sync': '跟随',

      // OTA
      'firmware_file': '固件文件',
      'clear_file': '清除文件',
      'ota_upgrade': 'OTA 升级',
      'upgrade_notes': '升级说明',
      'select_firmware': '点击选择固件文件',
      'supports_bin': '支持 .bin 格式',
      'ready': '准备就绪',
      'upgrade_success': '升级成功！',
      'upgrade_failed': '升级失败',
      'cancelled': '已取消',
      'preparing': '准备升级...',
      'upgrading': '升级中...',
      'please_select_file': '请先选择固件文件',
      'upgrade_in_progress': '升级已在进行中',

      // New OTA Keys
      'ota_preparing': '准备升级...',
      'ota_step_request': '正在发送升级请求...',
      'ota_step_finish': '正在结束...',
      'ota_step_finishing': '正在发送结束信号...',
      'ota_success': '升级成功！',
      'ota_failed': '升级失败',
      'ota_ready': '准备就绪',
      'ota_cancelled': '已取消',
      'ota_in_progress': '升级正在进行中',
      'ota_select_firmware_first': '请先选择固件文件',
      'ota_error_in_progress': '升级已在进行中',
      'ota_error_not_connected': '设备未连接',
      'ota_error_no_ack': '设备未响应升级请求',
      'ota_error_frame_failed': '数据帧发送失败',
      'ota_error_cancelled': '升级已取消',
      'ota_error_no_finish_ack': '未收到升级完成确认',
      'ota_error_device_rejected': '设备拒绝升级',
      'ota_firmware_name': '文件名',
      'ota_file_size': '文件大小',
      'ota_frame_count': '帧数量',
      'ota_status_connected': '设备已连接',
      'ota_status_disconnected': '设备未连接',
      'ota_connect_first': '请先连接设备后再进行升级',
      'ota_device_info': '设备参数',
      'ota_hw_version': '硬件版本',
      'ota_sw_version': '软件版本',
      'ota_car_model': '车型代码',
      'ota_packet_count': 'OTA帧数',
      'ota_cancel': '取消升级',
      'ota_start': '开始升级',
      'ota_step_1': '选择固件',
      'ota_step_1_desc': '点击上方区域选择 .bin 格式的固件文件',
      'ota_step_2': '连接设备',
      'ota_step_2_desc': '确保蓝牙设备已连接，状态显示"已连接"',
      'ota_step_3': '开始升级',
      'ota_step_3_desc': '点击"开始升级"按钮，升级过程中请勿断开设备',
      'ota_step_4': '等待完成',
      'ota_step_4_desc': '升级完成后设备会自动重启，请耐心等待',
      'ota_warning': '升级过程中请勿关闭应用或断开蓝牙连接，否则可能导致设备损坏',
      'ota_confirm_title': '确认升级',
      'ota_confirm_content': '确定要开始固件升级吗？升级过程中请勿断开设备连接。',

      // Factory Mode
      'factory_mode': '工厂模式',
      'exit_factory': '退出工厂模式',
      'led_config': '灯带安装配置 (分区设置)',
      'driver_side': '驾驶侧 (左)',
      'passenger_side': '副驾侧 (右)',
      'forward': '正向',
      'reverse': '反向',
      'led_unit': '颗',
      'device_reg': '设备注册',
      'vin_code': 'VIN 码 (17位)',
      'enter_vin': '输入车辆VIN码',
      'car_code': '车型编号',
      'func_code': '功能编号',
      'set': '设置',
      'register': '注册',
      'danger_zone': '危险操作',
      'factory_reset': '恢复出厂设置',
      'factory_reset_desc': '此操作将清除所有配置数据，不可恢复',
      'confirm_reset': '确认恢复',
      'cancel': '取消',
      'vin_must_17': 'VIN码必须为17位',
      'code_range': '0-255',
      'vin_sent': 'VIN码已发送',
      'code_set': '已设置',
      'reset_sent': '恢复出厂设置指令已发送',

      // New Factory Keys
      'factory_error_vin_length': 'VIN码必须为17位',
      'factory_vin_sent': 'VIN码已发送',
      'factory_error_car_model_range': '车型编号必须在 0-255 之间',
      'factory_car_model_set': '车型编号已设置',
      'factory_error_func_range': '功能编号必须在 0-255 之间',
      'factory_func_set': '功能编号已设置',

      // Remote Control
      'remote_control': '远程控制',
      'start_can': '启动 CAN',
      'start_lin': '启动 LIN',
      'stop_monitor': '停止',
      'save_log': '保存日志',
      'save_success': '保存成功: ',
      'save_failed': '保存失败: ',
      'no_data': '没有数据可保存',
      'select_location': '请选择保存位置:',
      'default_location': '默认位置 (文档)',
      'choose_location': '选择位置...',
      'total_records': '当前共有 ',
      'started_can': '开始 CAN 监控: ',
      'started_lin': '开始 LIN 监控: ',
      'stopped': '已停止监控',
      'seq': '序号',

      // Color Picker
      'hue': '色相',
      'saturation': '饱和度',
      'lightness': '亮度',

      // Sound Settings
      'sound_source': '律动音源',
      'builtin_mic': '内置麦克风',
      'car_speaker': '原车喇叭',
      'sensitivity': '律动灵敏度',
      'level': '档',

      // Advanced Features
      'advanced_features': '高级功能',
      'welcome_light': '迎宾灯',
      'door_link': '车门联动',
      'speed_response': '车速响应',
      'turn_link': '转向联动',
      'ac_link': '空调联动',
      'crash_warning': '碰撞警示',

      // Zones
      'main_driver': '主驾',
      'co_pilot': '副驾',
      'left_front': '左前门',
      'right_front': '右前门',
      'left_rear': '左后门',
      'right_rear': '右后门',

      // Common
      'loading': '加载中...',
      'success': '成功',
      'error': '错误',
      'warning': '警告',
      'confirm': '确认',
      'info': '提示',
      'action_cancel': '取消',
      'action_confirm': '确认',

      // Navigation / Sidebar
      'ambient_light': '氛围灯',
      'factory_mode_nav': '工厂模式',
      'ota_upgrade_nav': 'OTA升级',
      'scan_device': '扫描设备',
      'scan_searching': '正在搜索附近的设备...',
      'scan_no_devices': '未发现设备',
      'action_connect': '连接',
      'action_rescan': '重新扫描',

      // Device Card
      'device_connection': '设备连接',
      'light_settings': '灯光设置',
      'zone_brightness': '区域亮度',
      'zone_1': '区域一',
      'zone_2': '区域二',
      'zone_3': '区域三',
      'zone_4': '区域四',
      'zone_5': '区域五',
      'zone_6': '区域六',

      // Color Modes
      'solid_color': '单色',
      'multi_color': '多色',
      'rhythm': '律动',

      // Solid Color Mode
      'rgb_color_control': 'RGB 颜色控制',
      'color_selection': '颜色选择',
      'current_color': '当前颜色',
      'preset_colors': '常用颜色',
      'apply_color': '应用颜色',

      // Multi Color Mode
      'multi_rgb_control': '多色 RGB 控制',
      'dynamic_mode': '动态模式',
      'preset_schemes': '预设方案',
      'custom': '自定义',
      'preset_lakeside': '湖滨晴雨',
      'preset_lotus': '曲院风荷',
      'preset_sunset': '雷峰夕照',
      'preset_moonspring': '月泉晓彻',
      'preset_fishpond': '琼岛春阴',
      'preset_westlake': '西山晴雪',
      'preset_autumn': '平湖秋月',
      'preset_bamboo': '云栖竹径',
      'preset_lakeglow': '洞庭秋色',
      'preset_aurora': '无极渐变',

      // Rhythm Mode
      'rhythm_mode': '律动模式',
      'rhythm_effects': '律动效果',
      'mode_1': '模式 1',
      'mode_2': '模式 2',
      'mode_3': '模式 3',
      'mode_4': '模式 4',
      'mode_5': '模式 5',
      'mode_6': '模式 6',
      'mode_7': '模式 7',
      'mode_8': '模式 8',
      'rhythm_sensitivity': '律动灵敏度',
      'level_1': '1档',
      'level_2': '2档',
      'level_3': '3档',
      'level_4': '4档',
      'level_5': '5档',
    },
  };

  String get(String key) {
    // 1. Try current locale
    var value = _localizedValues[locale.languageCode]?[key];

    // 2. Try fallback to English (if current is not English)
    if (value == null && locale.languageCode != 'en') {
      value = _localizedValues['en']?[key];
    }

    // 3. Return key as last resort
    return value ?? key;
  }

  // Static access for easy use if needed (careful with context)
  static Map<String, String> get en => _localizedValues['en']!;
  static Map<String, String> get zh => _localizedValues['zh']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
