import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcp_lamp_flutter/presentation/widgets/common/glass_card.dart';
import 'package:ckcp_lamp_flutter/presentation/providers/preferences_provider.dart';
import 'package:ckcp_lamp_flutter/presentation/themes/colors.dart';
import 'package:ckcp_lamp_flutter/core/extensions/context_extensions.dart';
import 'package:ckcp_lamp_flutter/core/constants/app_info.dart';
import 'package:ckcp_lamp_flutter/core/services/app_update_service.dart';
import '../widgets/update/upgrade_dialog.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isCheckingUpdate = false;

  Future<void> _checkUpdate(BuildContext context) async {
    if (_isCheckingUpdate) return;

    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      // Show loading snackbar? Or just spinner.
      // Professional feel: Spinner in the tile is subtle and nice.

      final updateInfo = await AppUpdateService.instance.checkUpdate();

      if (!mounted) return;

      if (updateInfo != null) {
        _showUpdateDialog(context, updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('latest_version')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${context.tr('error')}: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  void _showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpgradeDialog(
        info: info,
        onIgnore: () => Navigator.pop(ctx),
        onUpdate: () {
          Navigator.pop(ctx);
          // Implement download logic here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.tr('settings_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionTitle(context, context.tr('appearance')),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('theme_mode'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      // Theme Selector
                      Row(
                        children: [
                          _buildThemeOption(
                            context,
                            context.tr('theme_light'),
                            Icons.light_mode,
                            prefs.themeMode == ThemeMode.light,
                            () => notifier.setThemeMode(ThemeMode.light),
                          ),
                          const SizedBox(width: 12),
                          _buildThemeOption(
                            context,
                            context.tr('theme_dark'),
                            Icons.dark_mode,
                            prefs.themeMode == ThemeMode.dark,
                            () => notifier.setThemeMode(ThemeMode.dark),
                          ),
                          const SizedBox(width: 12),
                          _buildThemeOption(
                            context,
                            context.tr('theme_system'),
                            Icons.brightness_auto,
                            prefs.themeMode == ThemeMode.system,
                            () => notifier.setThemeMode(ThemeMode.system),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, context.tr('language')),
              const SizedBox(height: 12),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildLanguageOption(
                        context,
                        '🇨🇳 ${context.tr('lang_zh')}',
                        prefs.locale.languageCode == 'zh',
                        () => notifier.setLocale(const Locale('zh')),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      _buildLanguageOption(
                        context,
                        '🇺🇸 ${context.tr('lang_en')}',
                        prefs.locale.languageCode == 'en',
                        () => notifier.setLocale(const Locale('en')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, context.tr('about')),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline,
                          color: AppColors.primary),
                      title: const Text(AppInfo.appName),
                      subtitle:
                          Text('${context.tr('version')} ${AppInfo.version}'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.system_update, // New Icon
                          color: AppColors.primary),
                      title: Text(context.tr('online_upgrade')),
                      trailing: _isCheckingUpdate
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _checkUpdate(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      title: const Text('Author'),
                      subtitle: const Text(AppInfo.author),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String label, IconData icon,
      bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
