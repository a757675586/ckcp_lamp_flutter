import 'package:flutter/material.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/extensions/context_extensions.dart';

class UpgradeDialog extends StatefulWidget {
  final AppUpdateInfo? info;
  final VoidCallback onIgnore;
  final VoidCallback? onUpdate;

  const UpgradeDialog({
    super.key,
    this.info,
    required this.onIgnore,
    this.onUpdate,
  });

  @override
  State<UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog> {
  AppUpdateInfo? _updateInfo;
  bool _isDownloading = false;
  bool _isChecking = false;
  double _progress = 0.0;
  String? _errorMessage;
  String? _downloadedFilePath;

  // State for Window
  Offset? _position;
  Size _size = const Size(700, 450);

  @override
  void initState() {
    super.initState();
    _updateInfo = widget.info;
    // Auto-check on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _updateInfo = null;
    });

    try {
      final info = await AppUpdateService.instance.checkUpdate();
      if (mounted) {
        setState(() {
          _isChecking = false;
          _updateInfo = info; // Set even if null for display
        });
        if (info == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('latest_version'))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (_updateInfo == null) return;

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      final path = await AppUpdateService.instance.downloadUpdate(
        _updateInfo!.downloadUrl,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedFilePath = path;
          _progress = 1.0;
        });

        _installUpdate();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _installUpdate() {
    if (_downloadedFilePath != null) {
      AppUpdateService.instance.launchInstaller(_downloadedFilePath!);
    }
  }

  void _openWebsite() {
    AppUpdateService.instance
        .openUrl('https://github.com/a757675586/ckcp_lamp_flutter');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Initialize position to center if null
        if (_position == null) {
          final center = Offset(
            (constraints.maxWidth - _size.width) / 2,
            (constraints.maxHeight - _size.height) / 2,
          );
          _position = center;
        }

        return Stack(
          children: [
            // Barrier (Visual only, Logic handled by Positioned)
            GestureDetector(
              onTap: () {
                // Optional: Close on outside tap? Standard dialogs usually do.
                // Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black54),
            ),

            // Draggable Window
            Positioned(
              left: _position!.dx,
              top: _position!.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = _position! + details.delta;
                  });
                },
                child: Material(
                  color: Colors.transparent,
                  elevation: 24,
                  shadowColor: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: _size.width,
                    height: _size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // Title Bar (Draggable Area)
                            Container(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  Text(
                                    context.tr('upgrade_title'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _isDownloading
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Body content
                            Expanded(child: _buildBody(context)),
                          ],
                        ),

                        // Resize Handle (Bottom Right)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                final newWidth = _size.width + details.delta.dx;
                                final newHeight =
                                    _size.height + details.delta.dy;
                                // Minimum size constraints
                                _size = Size(
                                  newWidth.clamp(600.0, 1200.0),
                                  newHeight.clamp(400.0, 900.0),
                                );
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              color: Colors.transparent, // Hit test area
                              alignment: Alignment.bottomRight,
                              child: const Icon(
                                Icons.south_east,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      children: [
        // Left Column: Basic Info
        Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_upload,
                      size: 32, color: Color(0xFF1E88E5)),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('upgrade_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoRow(
                  context, 'update_source', _updateInfo?.source ?? '-'),
              _buildInfoRow(context, 'current_version', AppInfo.version),
              _buildInfoRow(context, 'latest_version_label',
                  _updateInfo?.version ?? context.tr('unknown') ?? 'Unknown',
                  isHighLight: true),
              _buildInfoRow(
                  context, 'release_date', _updateInfo?.releaseDate ?? '-'),
              const Spacer(),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    maxLines: 2,
                  ),
                ),
              if (_isDownloading) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text(
                  '${context.tr('downloading')} ${(_progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : _checkUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(context.tr('check_update')),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openWebsite,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(context.tr('official_download')),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _downloadedFilePath != null
                        ? _installUpdate
                        : (_updateInfo != null && _updateInfo!.hasUpdate
                            ? _startDownload
                            : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _downloadedFilePath != null
                          ? Colors.green
                          : (_updateInfo != null && _updateInfo!.hasUpdate
                              ? const Color(0xFF1E88E5)
                              : Colors.grey),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(_downloadedFilePath != null
                        ? context.tr('install_update')
                        : context.tr('start_update')),
                  ),
                ),
              ]
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('new_version_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _updateInfo?.content ??
                          context.tr('no_update_info') ??
                          'Click Check Update to see details.', // Fallback
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String labelKey, String value,
      {bool isHighLight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr(labelKey),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighLight ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
